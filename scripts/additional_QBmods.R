library(tidyverse)
library(here)
library(mgcv)
library(itsadug)
library(nzilbb.labbcat)

labbcat.url <- "https://labbcat.canterbury.ac.nz/quakestudies/"

# additional QB models.

QB1 <- read_rds(here('data', 'QB1.rds'))

# getLayerIds(labbcat.url)
# 
# # get celex frequency
# freq <- getMatchLabels(
#   labbcat.url,
#   QB1$MatchId,
#   "celex frequency"
# )
# 
# # ADD TO QB1 data and save.
# QB1 <- QB1 |> 
#   mutate(
#     celex_freq = freq
#   )
# 
# 
# QB1 <- QB1 |> 
#   mutate(
#     celex_freq = celex_freq$celex.frequency
#   )
# 
# write_rds(QB1, here('data', 'QB1.rds'))

levels(QB1$Age)
# output: "18-25" "26-35" "36-45" "46-55" "56-65" "66-75" "76-85" "85+"   "na" 
# Correct!

# Convert to integer and do to factor conversions for speaker and word.
QB1 <- QB1 %>%
  mutate(
    age_category_numeric = as.integer(Age),
    Speaker = as.factor(Speaker),
    Gender = as.factor(Gender),
    Word = as.factor(Word),
    log_freq = log(celex_freq + 1),
    s_log_freq = scale(log_freq),
    s_age_cat = scale(age_category_numeric)
  )

QB1_caregivercount <- QB1 |> 
  filter(
    Vowel %in% c(
      "DRESS",
      "FLEECE",
      "TRAP",
      "KIT",
      "NURSE"
    ),
    Gender == "F",
    age_category_numeric %in% c(1, 2)
  ) |> 
  mutate(
    n = n_distinct(Speaker)
  )

QB1_oldestgeneration <- QB1 |> 
  filter(
    Vowel %in% c(
      "DRESS",
      "FLEECE",
      "TRAP",
      "KIT",
      "NURSE"
    ),
    age_category_numeric == 7
  ) |> 
  mutate(
    n = n_distinct(Speaker)
  )

QB1_caregivercount$n[[1]]  
QB1_oldestgeneration$n[[1]]  

# test mod
test_data <- QB1 |>
  filter(
    Age != "85+"
  ) %>%
  select(
    -F1_50, -F2_50
  ) %>%
  pivot_longer(
    cols = F1_lob2:F2_lob2,
    names_to = "formant_type",
    values_to = "formant_value"
  ) |> 
  filter(
    Vowel == "DRESS",
    formant_type == "F1_lob2"
  )

test_mod <- bam(
  formant_value ~ Gender + te(age_category_numeric,log_freq, k = 4, by = Gender) + # main effects
    s(articulation_rate, k = 3) + # control vars
    s(Speaker, bs='re') + s(Word, bs='re'), # random effects
  discrete = TRUE,
  nthreads = 4, 
  family = mgcv::scat(link ='identity'),
  data = test_data
)

gam.check(test_mod)

summary(test_mod)

pvisgam(test_mod, view = c("age_category_numeric", "log_freq"), cond = list(Gender = "F"))

print(test_data)


f_QB1 <- QB1 |> filter(
  Vowel %in% c(
      "DRESS",
      "FLEECE",
      "TRAP",
      "KIT",
      "NURSE"
    )
  )

f_QB1 |>  
  group_by(Speaker) |> 
  summarise(Gender = first(Gender), Age = first(Age)) |> 
  summary()

#We've only got one 85+ speaker, so we remove the 85+ category.


QB1_models <- QB1 %>%
  filter(
    Age != "85+"
  ) %>%
  select(
    -F1_50, -F2_50
  ) %>%
  pivot_longer(
    cols = F1_lob2:F2_lob2,
    names_to = "formant_type",
    values_to = "formant_value"
  ) %>%
  group_by(Vowel, formant_type) %>%
  nest() %>%
  mutate(
    model = map(
      data,
      ~ bam(
          formant_value ~ Gender + te(age_category_numeric, s_log_freq, k = c(4, 10), by = Gender) + # main effects
            s(articulation_rate, k = 10) + # control vars
            s(Speaker, bs='re') + s(Word, bs='re'), # random effects
          discrete = TRUE,
          nthreads = 4, # This value is too high for most situations.
          family = mgcv::scat(link ='identity'),
          data = .x
      )
    )
  )

write_rds(QB1_models, here('models', 'QB1_freq_models.rds'))


QB1_models <- QB1 %>%
  filter(
    Age != "85+"
  ) %>%
  select(
    -F1_50, -F2_50
  ) %>%
  pivot_longer(
    cols = F1_lob2:F2_lob2,
    names_to = "formant_type",
    values_to = "formant_value"
  ) %>%
  group_by(Vowel, formant_type) %>%
  nest() %>%
  mutate(
    model = map(
      data,
      ~ bam(
        formant_value ~ Gender + s(age_category_numeric, k = 4, by = Gender) + # main effects
          s(articulation_rate, k = 10) + # control vars
          s(Speaker, bs='re') + s(Word, bs='re'), # random effects
        discrete = TRUE,
        nthreads = 4, # This value is too high for most situations.
        family = mgcv::scat(link ='identity'),
        data = .x
      )
    )
  )

write_rds(QB1_models, here('models', 'QB1_models.rds'))

caregiver_preds <- function(model) {
  get_predictions(
    model,
    cond = list(
      Gender = "F",
      age_category_numeric = c(1,2)
    )
  )
}

oldest_preds <- function(model) {
  get_predictions(
    model,
    cond = list(
      Gender = c("M", "F"),
      age_category_numeric = 8
    )
  )
}

QB1_models <- QB1_models |> 
  mutate(
    cg_pred = map(model, caregiver_preds),
    oldest_pred = map(model, oldest_preds)
  )

preds <- QB1_models |> 
  select(Vowel, formant_type, cg_pred, oldest_pred) |> 
  pivot_longer(
    cols = c("cg_pred", "oldest_pred"),
    names_to = "prediction_type",
    values_to = "pred_value"
  ) |> 
  unnest(pred_value)

plot_preds <- preds |> 
  group_by(Vowel, formant_type, Gender, prediction_type) |> 
  summarise(
    mean_formant_value = mean(fit)
  ) |> 
  pivot_wider(
    names_from = formant_type, values_from = mean_formant_value
  )

plot_preds |> 
  filter(
    Vowel %in% c("DRESS", "FLEECE", "NURSE", "TRAP", "KIT")
  ) |> 
  ggplot(
    aes(
      x = F2_lob2,
      y = F1_lob2,
      colour = Vowel,
      shape = prediction_type
    )
  ) +
  geom_point() +
  scale_x_reverse() +
  scale_y_reverse() +
  facet_wrap(vars(Gender))

plot_smooth(QB1_models$model[[1]])
