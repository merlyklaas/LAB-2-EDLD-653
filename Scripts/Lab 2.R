---
  title: "EDLD 653 Lab 2"
output: html_document
Name  : Merly Klaas
---
  
  ```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## R Markdown

This is an R Markdown document. Markdown is a simple formatting syntax for authoring HTML, PDF, and MS Word documents. For more details on using R Markdown see <http://rmarkdown.rstudio.com>.

When you click the **Knit** button a document will be generated that includes both content as well as the output of any embedded R code chunks within the document. You can embed an R code chunk like this:
  
  ```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

```{r}
library(tidyverse)
library(repurrrsive)
library(httr)
```

# Part A: Multiple Models

## Run the code below to load the following dataset.

```{r}
file <- "https://github.com/datalorax/esvis/raw/master/data/benchmarks.rda"
load(url(file))
head(benchmarks)
```

## Recode season to wave with the following code

```{r}
benchmarks <- benchmarks %>%
  as_tibble() %>%
  mutate(wave = case_when(season == "Fall" ~ 0,
                          season == "Winter" ~ 1,
                          TRUE ~ 2))
```

## 1. Fit a model of the form lm(math ~ wave) for each student.

```{r}
#Fit a model of the form lm(math ~ wave) for each student.
by_student <- split(benchmarks, benchmarks$sid)
mods <- map(by_student, ~lm(math~wave, data=.x))
##Plot the distribution of slopes. Annotate the plot with a vertical line for the mean
coefs <-map(mods, coef)
coefs [c(1:2, length(coefs))]
slopes <- map_dbl(coefs, 2)
slopes
```

## 2. Plot the distribution of slopes. Annotate the plot with a vertical line for the mean

```{r}
relation <- tibble(student = names(slopes),
                   slope = slopes)
plot1 <- 
  ggplot(relation, aes(slope)) +
  geom_histogram(fill = "cornflowerblue",
                 color = "white") +
  geom_vline(aes(xintercept=mean(slope, na.rm = T)))
plot1
ggsave(here::here("plot","by student.pdf"))
```

# Part B: Star Wars

## 1. Use the sw_films list to identify how many characters were represented in each film.

```{r}
characters_per <- map_dbl(sw_films, ~length(.x$characters))
characters_per
```

## 2. Use the sw_species list to 

### (a) identify species that have known hair colors  

```{r}
hair_colors <- 
  tibble(species_name = map_chr(sw_species, ~.x$name),
         hair_color = map_chr(sw_species, ~.x$hair_colors) 
  ) %>% 
  mutate(known = if_else(hair_color != 'n/a' &
                           hair_color != 'none' &
                           hair_color != 'unknown', T, F))
hair_colors %>% 
  filter(known == T)
```

### (b) identify what those hair colors are.

```{r}
hair_colors %>% 
  filter(known == T) %>% 
  select(hair_color) %>% 
  unique()
```

# Part C: Some basic API calls


## 1. Use {purrr} to write an API call to obtain data on the first five abilities (note, we’re only using the first five to make the calls go fast, but the code would be essentially equivalent for any number of abilities you wanted to query). Make sure you parse the JSON data to a list.

```{r}
link <- "https://pokeapi.co/api/v2/ability/"
character_vector <- paste0(link, 1:5)
```

```{r}
abilities <- 
  map(character_vector, 
      ~GET(.x) %>% 
        content('parsed'))
```

## 2. Use the parsed data to create a data frame that has the given ability, and the number of pokemon with that ability.

```{r}
ability_dat <- 
  tibble(ability_name = map_chr(abilities, ~.x$name), 
         number = map_chr(abilities, ~length(.x$pokemon)))
ability_dat
```

Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.
