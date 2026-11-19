# сarregar os dados CPSSWEducation do pacote AER
library(AER)
data("CPSSWEducation")
str(CPSSWEducation)
CPSSWEducation

# selecionar as variáveis:
df <- CPSSWEducation
df1 <- df[c("gender", "earnings", "education")] 

# сriar uma variável categórica educ2
df1$educ2 <- ""
df1$educ2[df$education < 12] <- "sec"
df1$educ2[df$education >= 12] <- "uni"
df1

# garantir que variáveis categóricas são fatores
df1$gender <- factor(df1$gender, levels = c("female","male"))
df1$educ2  <- factor(df1$educ2, levels = c("sec","uni"))

str(df1) # para verificar a estrutura do data frame
table(df1$gender, df1$educ2)   # mostra o desequilíbrio das amostras


#gráficos de interação
# Boxplot de earnings por gender
boxplot(earnings ~ gender, data = df1,
        main = "Earnings por Gender",
        xlab = "Gender",
        ylab = "Earnings")

# Boxplot de earnings por educ2
boxplot(earnings ~ educ2, data = df1,
        main = "Earnings por Nível de Educação (educ2)",
        xlab = "Nível de Educação",
        ylab = "Earnings")

# Boxplot combinado com os dois factores
boxplot(earnings ~ gender:educ2, data = df1,
        main = "Earnings por Gender e Nível de Educação",
        xlab = "Gender : Educação",
        ylab = "Earnings",
        las = 2)

# o gráfico de interação
interaction.plot(df1$educ2, df1$gender, df1$earnings,
                 main = "Gráfico de Interação entre Educação e Género nos Rendimentos",
                 xlab = "Nível de Educação",
                 ylab = "Earnings Médios",
                 trace.label = "Gender",
                 col = c("red", "blue")
)


# Ajustar o modelo ANOVA de dois fatores com interação
rendimento<- aov(earnings ~ gender * educ2, data = df1)
summary(rendimento)

# Teste de comparações múltiplas de Tukey
tukey <- TukeyHSD(rendimento)
tukey

res <- residuals(rendimento)

#QQ-plot para verificar normalidade
qqnorm(res)
qqline(res, col = "red")

# Teste de normalidade de Shapiro-Wilk 
shapiro.test(res)

# Gráfico de resíduos versus valores ajustados
plot(fitted(rendimento), res,
     xlab = "Valores Ajustados", ylab = "Resíduos",
     main = "Resíduos vs Valores Ajustados")
abline(h = 0, col = "red")

# Teste de Homogeneidade das variâncias 
df1$grupo <- interaction(df1$gender, df1$educ2)
bartlett.test(earnings ~ grupo, data = df1)
leveneTest(earnings ~ grupo, data = df1)   # Levene (pacote car): mais robusto à falta de normalidade

# Teste de independência dos resíduos
dwtest(rendimento)


# Criar a nova variável log-transformada
df1$log_earnings <- log(df1$earnings)
summary(df1$log_earnings)

# Boxplot com log(earnings) para os dois factores combinados
boxplot(log_earnings ~ gender:educ2, data = df1,
        main = "log(Earnings) por Gender e Nível de Educação",
        xlab = "Gender : Educação",
        ylab = "log(Earnings)",
        col = c("lightblue", "lightgreen", "lightpink", "lightgray"))


interaction.plot(df1$educ2, df1$gender, df1$log_earnings,
                 main = "Gráfico de Interação entre Educação e Género nos log(Earnings)",
                 xlab = "Nível de Educação",
                 ylab = "log(Earnings) Médios",
                 trace.label = "Gender",
                 col = c("red", "blue"))

# mostra que delineamento não equilibrado
table(df1$gender, df1$educ2)  
library(WRS2)

# Welch ANOVA para dois factores (gender e educ2) usando log(earnings)
welch_two_way <- t2way(log_earnings ~ gender * educ2, data = df1)
welch_two_way

# Comparações múltiplas robustas entre os grupos
mcp2atm(log_earnings ~ gender + educ2, data = df1)


# PARTE 2

# Carregar a library
library(MASS)

# Carregar a data para a manipulação de dados
data("Boston")

# Modelo completo
mod_full <- lm(medv ~ age + crim + rm + lstat, data = Boston)

summary(mod_full)
anova(mod_full)

#  Residual Analysis mod_full

qqnorm(residuals(mod_full))
qqline(residuals(mod_full), col = "green")

# Teste de normalidade
shapiro.test(residuals(mod_full))

# Homogeneidade de varianças

plot(fitted(mod_full), rstandard(mod_full),main="Standardized residuals vs Fitted")
abline(h=0)

bptest(mod_full)   # Breusch-Pagan

# independence of residuals
plot(fitted(mod_full), resid(mod_full), main="residuals vs Fitted")
abline(h=0, col = "red")

# Durbin-Watson for independence it requires lmtest package

dwtest(mod_full)

# Teste de multicolinearidade
vif(mod_full)

# Usar o STEP!!!
mod_step <- step(mod_full, direction = "both", trace = FALSE)
summary(mod_step)

#Modelo não linear
mod_nl <- lm(medv ~ rm + age + lstat + I(lstat^2) + log(crim + 1), data = Boston)
summary(mod_nl)

#Modelo de interação
mod_int <- lm(medv ~ rm * lstat + age + log(crim + 1), data = Boston)
summary(mod_int)

#AIC ESCOLHER O MELHOR
AIC(mod_step, mod_nl, mod_int)
anova(mod_step, mod_nl)
anova(mod_step, mod_int)
anova(mod_nl, mod_int)

coef(mod_int)

# Função para calcular efeito marginal
efeito_rm <- function(lstat_value) {
  b_rm  <- coef(mod_int)["rm"]
  b_int <- coef(mod_int)["rm:lstat"]
  b_rm + b_int * lstat_value
}

# Exemplo: valores baixos, médios e altos de lstat
efeito_rm(5)
efeito_rm(10)
efeito_rm(20)

library(ggplot2)

ggplot(Boston, aes(x = rm, y = medv, colour = lstat)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", formula = y ~ x * lstat) +
  theme_minimal()
