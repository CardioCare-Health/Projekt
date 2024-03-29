#install.packages("shiny")
# app.R

#Potrzebne biblioteki
library(ggplot2)
library(corrplot)
library(readr)
library("car") # funkcja vif()
library("pscl") #pseudo-R2 funkcja pR2()
#Potrzebne biblioteki
library(ggplot2)
library(corrplot)
library(readr)
library("car") # funkcja vif()
library("pscl") #pseudo-R2 funkcja pR2()
library("pROC") #funkcje roc, auc
library("lmtest")



#Import danych
heart <- read_csv("heart1.csv")

#Przygotowanie typu zmiennych
class(heart$Sex)
class(heart$ExerciseAngina)
class(heart$HeartDisease)

class(heart$MaxHR)
class(heart$Cholesterol)
class(heart$RestingBP)
class(heart$Age)

#zmiana typu zmiennych 
heart$Sex <- factor(heart$Sex)
heart$ExerciseAngina <- factor(heart$ExerciseAngina)
heart$HeartDisease <- factor(heart$HeartDisease)

heart$MaxHR <- as.numeric(heart$MaxHR)
heart$Cholesterol <- as.numeric(heart$Cholesterol)
heart$RestingBP <- as.numeric(heart$RestingBP)
heart$Age <- as.numeric(heart$Age)

class(heart$Sex)
class(heart$ExerciseAngina)
class(heart$HeartDisease)

class(heart$MaxHR)
class(heart$Cholesterol)
class(heart$RestingBP)
class(heart$Age)

#Wstępna weryfikacja poprawności danych

#Ze zbioru danych usuniemy dane, z któych nie będziemy korzystać w badaniu.

summary(heart)
heart[heart$Cholesterol == 0, ]
nrow(heart[heart$Cholesterol == 0, ])
heart[heart$RestingBP == 0, ]
nrow(heart) - nrow(heart[heart$Cholesterol == 0, ])
heart_1= heart

#rozrzut zmiennej Cholesterol przed usunięciem danych.
par(bg = "#F5F5F5")
plot(heart_1$Cholesterol,
     lty = 2,
     lwd = 1,
     main = "Cholesterol",
     col.main = "Black",
     xlab = "Observation",
     ylab = "Cholesterol mg/dl",
     col = "darkblue")


#Usunięcie jednostek
heart_2 = heart_1[heart_1$Cholesterol > 0,]

par(bg = "#F5F5F5")
plot(heart_2$Cholesterol,
     lty = 2,
     lwd = 1,
     main = "Cholesterol",
     col.main = "Black",
     xlab = "Observation",
     ylab = "Cholesterol mg/dl",
     col = "darkblue")


#Analiza wstępna
#podstawowe statystyki zbioru danych
summary(heart_2)


# Sex - Płec
M <- table(heart_2$Sex, exclude = "F")/nrow(heart_2) * 100
K <- table(heart_2$Sex, exclude = "M")/nrow(heart_2) * 100
print(M)
print(K)

par(bg = "#F5F5F5")
Struktura_plci <- c(M, K)

result <- pie(Struktura_plci,
              main = "Struktura płci",
              labels = c("M", "K"),
              col = c("lightblue", "pink")
)

legend("topright", c("M 75.6%", "K 24.4%"), cex = 0.8,
       fill = c("lightblue", "pink"))
print(result)



#Age - Wiek
heart_2$Age_2 <- recode(heart_2$Age, "28:41 ='<42'; 42:53= '42-53' ; 54:60='54-60' ;else = '>60'")
table(heart_2$Age_2)

#macierz danych, obrazującą liczebności jednsotek w poszczególnej grupie wiekowej w zależności od płci.
Dane <- matrix(c(table(heart_2$Age_2[heart_2$Sex == "M"])[1], table(heart_2$Age_2[heart_2$Sex == "M"])[2], table(heart_2$Age_2[heart_2$Sex == "M"])[3], table(heart_2$Age_2[heart_2$Sex == "M"])[4], table(heart_2$Age_2[heart_2$Sex == "F"])[1], table(heart_2$Age_2[heart_2$Sex == "F"])[2], table(heart_2$Age_2[heart_2$Sex == "F"])[3], table(heart_2$Age_2[heart_2$Sex == "F"])[4]), nrow = 2, ncol = 4, byrow = TRUE)
rownames(Dane) = c("M", "F")
colnames(Dane) = c("<42", "42-53", "54-60", ">60")
Dane


#Wizualizacja danych.
par(bg = "#F5F5F5")
barplot(Dane,
        main = "Struktura wieku ze względu na płeć",
        xlab = "Grupa wiekowa",
        ylab = "Liczebność",
        col = c("lightblue","pink")
)
legend("topleft",
       c("M","F"),
       fill = c("lightblue","pink")
)

#RestingBP - Spoczynkowe ciśnienie krwi  [mm Hg]
par(bg = "#F5F5F5")
boxplot(x = heart_2$RestingBP, boxwex = 0.5, col = c("lightblue"),
        main = "Box Plot - Spoczynkowe ciśnienie krwi",
        ylab = "RestingBP [mm Hg]",
        ylim = c(90, 210))

heart_2[heart_2$RestingBP > (quantile(heart_2$RestingBP, 0.75) - quantile(heart_2$RestingBP, 0.25)) * 1.5 + quantile(heart_2$RestingBP, 0.75),]

par(bg = "#F5F5F5")
q <- qqnorm(heart_2$RestingBP, main = "Normal Q-Q Plot",
            pch = 1,
            lwd = 1,
            col = "darkcyan",
            frame = FALSE,
            xlab = "Theoretical Quantiles", ylab = "Sample Quantiles - RestingBP [mm Hg]",
            plot.it = TRUE, datax = FALSE)

q + scale_color_manual(values=c("red"))

qqline(heart_2$RestingBP, datax = FALSE, distribution = qnorm,
       probs = c(0.25, 0.75), qtype = 7, col = "red", lwd = 2)

wykres <- ggplot(heart_2, aes(x = RestingBP, fill = Sex)) + geom_histogram(binwidth = 15) + xlab(label = "RestingBP [mm Hg]") + ylab(label = "Count") + ggtitle("Histogram liczebności pod \n względem spoczynkowego ciśnienia krwi i płci") +
  theme(plot.title = element_text(color="black", size=14, face="bold.italic",    hjust = 0.5),
        axis.title.x = element_text(color="black", size=14, face="bold"),
        axis.title.y = element_text(color="black", size=14, face="bold"),
        axis.line = element_line(colour = "black", size = 1, linetype = "solid"),
        axis.text.x = element_text(face = "bold.italic", color="black", size=11),
        axis.text.y = element_text(face = "bold.italic", color="black", size=11),
        plot.background = element_rect(fill = "gray"))

wykres + scale_fill_manual(values = c("pink", "lightblue")) + theme(panel.background = element_rect(fill = "#EBEBEB"))

#Cholesterol 
par(bg = "#F5F5F5")
boxplot(x = heart_2$Cholesterol, boxwex = 0.5, col = c("lightblue"),
        main = "Box Plot - Cholesterol",
        ylab = "Cholesterol [mg/dl]",
        ylim = c(80, 630))

#Jednostki skrajnie wysokie:
heart_2[heart_2$Cholesterol > (quantile(heart_2$Cholesterol, 0.75) - quantile(heart_2$Cholesterol, 0.25)) * 1.5 + quantile(heart_2$Cholesterol, 0.75),]

#Jednostki skrajnie niskie:
heart_2[heart_2$Cholesterol <  quantile(heart_2$Cholesterol, 0.25) - (quantile(heart_2$Cholesterol, 0.75) - quantile(heart_2$Cholesterol, 0.25)) * 1.5,]

#Wykres kwantylowy
par(bg = "#F5F5F5")
q <- qqnorm(heart_2$Cholesterol, main = "Normal Q-Q Plot",
            pch = 1,
            lwd = 1,
            col = "darkcyan",
            frame = FALSE,
            xlab = "Theoretical Quantiles", ylab = "Sample Quantiles - Cholesterol [mg/dl]",
            plot.it = TRUE, datax = FALSE)

q + scale_color_manual(values=c("red"))

qqline(heart_2$Cholesterol, datax = FALSE, distribution = qnorm,
       probs = c(0.25, 0.75), qtype = 7, col = "red", lwd = 2)

wykres <- ggplot(heart_2, aes(x = Cholesterol, fill = Sex)) + geom_histogram(binwidth = 15) + xlab(label = "Cholesterol [mg/dl]") + ylab(label = "Count") + ggtitle("Histogram liczebności pod \n względem poziomu cholesterolu i płci") +
  theme(plot.title = element_text(color="black", size=14, face="bold.italic",    hjust = 0.5),
        axis.title.x = element_text(color="black", size=14, face="bold"),
        axis.title.y = element_text(color="black", size=14, face="bold"),
        axis.line = element_line(colour = "black", size = 1, linetype = "solid"),
        axis.text.x = element_text(face = "bold.italic", color="black", size=11),
        axis.text.y = element_text(face = "bold.italic", color="black", size=11),
        plot.background = element_rect(fill = "gray"))

wykres + scale_fill_manual(values = c("pink", "lightblue")) + theme(panel.background = element_rect(fill = "#EBEBEB"))


#MaxHR - Osiągalne maksymalne tętno

par(bg = "#F5F5F5")
boxplot(x = heart_2$MaxHR, boxwex = 0.5, col = c("lightblue"),
        main = "Box Plot - Osiągalne maksymalne tętno",
        ylab = "MaxHR",
        ylim = c(70, 210))

mean(heart_2$MaxHR)
median(heart_2$MaxHR)

#wykres kwantylowy.
par(bg = "#F5F5F5")
q <- qqnorm(heart_2$MaxHR, main = "Normal Q-Q Plot",
            pch = 1,
            lwd = 1,
            col = "darkcyan",
            frame = FALSE,
            xlab = "Theoretical Quantiles", ylab = "Sample Quantiles - MaxHR",
            plot.it = TRUE, datax = FALSE)

q + scale_color_manual(values=c("red"))

qqline(heart_2$MaxHR, datax = FALSE, distribution = qnorm,
       probs = c(0.25, 0.75), qtype = 7, col = "red", lwd = 2)

wykres <- ggplot(heart_2, aes(x = MaxHR, fill = Sex)) + geom_histogram(binwidth = 10) + xlab(label = "MaxHR") + ylab(label = "Count") + ggtitle("Histogram liczebności pod \n względem maksymalnego osiągalnego tętna i płci") +
  theme(plot.title = element_text(color="black", size=14, face="bold.italic",    hjust = 0.5),
        axis.title.x = element_text(color="black", size=14, face="bold"),
        axis.title.y = element_text(color="black", size=14, face="bold"),
        axis.line = element_line(colour = "black", size = 1, linetype = "solid"),
        axis.text.x = element_text(face = "bold.italic", color="black", size=11),
        axis.text.y = element_text(face = "bold.italic", color="black", size=11),
        plot.background = element_rect(fill = "gray"))

wykres + scale_fill_manual(values = c("pink", "lightblue")) + theme(panel.background = element_rect(fill = "#EBEBEB"))


#ExerciseAngina - Dławica wywołana wysiłkiem

Dane <- matrix(c(table(heart_2$ExerciseAngina[heart_2$Sex == "M"])[1], table(heart_2$ExerciseAngina[heart_2$Sex == "M"])[2], table(heart_2$ExerciseAngina[heart_2$Sex == "F"])[1], table(heart_2$ExerciseAngina[heart_2$Sex == "F"])[2]), nrow = 2, ncol = 2, byrow = TRUE)
rownames(Dane) = c("M", "F")
colnames(Dane) = c("N", "Y")
Dane

#Wizualizujemy uzyskane dane.
par(bg = "#F5F5F5")
barplot(Dane,
        main = "Występowanie dławicy wywołanej wysiłkiem ze względu na płeć",
        xlab = "N - Nie wsytąpiła / Y - Wystąpiła",
        ylab = "Liczebność",
        col = c("lightblue","pink"),
        ylim = c(0, 500),
)
legend("topright",
       c("M","F"),
       fill = c("lightblue","pink")
)
grupa_1 <- Dane[2] / (Dane[1] + Dane[2]) * 100
grupa_2 <- Dane[4] / (Dane[3] + Dane[4]) * 100
grupa_1
grupa_2
wynik <- grupa_1 - grupa_2
wynik

#HeartDisease - Występowanie chorób serca
Dane <- matrix(c(table(heart_2$HeartDisease[heart_2$Sex == "M"])[1], table(heart_2$HeartDisease[heart_2$Sex == "M"])[2], table(heart_2$HeartDisease[heart_2$Sex == "F"])[1], table(heart_2$HeartDisease[heart_2$Sex == "F"])[2]), nrow = 2, ncol = 2, byrow = TRUE)
rownames(Dane) = c("M", "F")
colnames(Dane) = c("0", "1")
Dane

#Wizualizujemy uzyskane dane.
par(bg = "#F5F5F5")
barplot(Dane,
        main = "Występowanie chorób serca ze względu na płeć",
        xlab = "0 - Nie wsytąpiły / Y - Wystąpiły",
        ylab = "Liczebność",
        col = c("lightblue","pink"),
        ylim = c(0, 500),
)
legend("topright",
       c("M","F"),
       fill = c("lightblue","pink")
)

grupa_1 <- Dane[3] / (Dane[3] + Dane[4]) * 100
grupa_2 <- Dane[1] / (Dane[1] + Dane[2]) * 100
grupa_1
grupa_2
wynik <- grupa_1 - grupa_2
wynik


#MODELE LOGITOWE 
cdplot(heart_2$Cholesterol, heart_2$HeartDisease, xlab = "Poziom Cholesterolu", ylab = "Choroba serca", col = c("lightblue", "lightpink"))
cdplot(heart_2$MaxHR, heart_2$HeartDisease, xlab = "Maksymalne osiągalne tętno", ylab = "Choroba serca", col = c("lightblue", "lightpink"))
cdplot(heart_2$Age, heart_2$HeartDisease, xlab = "Wiek", ylab = "Choroba serca", col = c("lightblue", "lightpink"))
cdplot(heart_2$RestingBP, heart_2$HeartDisease, xlab = "Spoczynkowe tętno", ylab = "Choroba serca", col = c("lightblue", "lightpink"))

#Podział zbioru na uczący i testowy**
set.seed(1257) #set.seed(NULL) --> usunięcie "ziarna"
n <- nrow(heart_2) #zlicza wiersze
liczby_losowe <- sample(c(1:n), round(0.7*n), replace = FALSE) #replace-losowanie bez powtarzania
heart_uczacy <- heart_2[liczby_losowe,]
heart_testowy <- heart_2[-liczby_losowe,]

#Udział braku występowania oraz występowania choroby serca w ogólnej liczbie jednostek.
table(heart_2$HeartDisease)/nrow(heart_2)

#Udział braku występowania oraz występowania choroby serca w zbiorze uczącym.
table(heart_uczacy$HeartDisease)/nrow(heart_uczacy)

#Udział braku występowania oraz występowania choroby serca w zbiorze testowy.

table(heart_testowy$HeartDisease)/nrow(heart_testowy)

#Sprawdzenie korelacji parami zmiennych objaśniających

#Macierz korelacji dla objaśniających zmiennych ilościowych
cor(heart_uczacy[,c(1,3,4,5)])


#MODELe LINIOWE
modlm1 <- lm(Cholesterol ~ MaxHR, data = heart_uczacy)
summary(modlm1)

modlm2 <- lm(Cholesterol ~ Sex, data = heart_uczacy)
summary(modlm2)

modlm3 <- lm(RestingBP ~ ExerciseAngina, heart_uczacy)
summary(modlm3)

#Estymacja modeli dwumianowych logitowych jednoczynnikowych 
logit1 <- glm(HeartDisease ~ Age, data = heart_uczacy, family = binomial)
summary(logit1)

logit2 <- glm(HeartDisease ~ Cholesterol, data = heart_uczacy, family = binomial)
summary(logit2)

logit3 <- glm(HeartDisease ~ Sex, data = heart_uczacy, family = binomial)
summary(logit3)

logit4 <- glm(HeartDisease ~ MaxHR, data = heart_uczacy, family = binomial)
summary(logit4)

logit5 <- glm(HeartDisease ~ RestingBP, data = heart_uczacy, family = binomial)
summary(logit5)

logit6 <- glm(HeartDisease ~ ExerciseAngina, data = heart_uczacy, family = binomial)
summary(logit6)

#Porównanie dobroci dopasowania modeli logitowych

ocena_modelu_dwum <- function(model) {
  kryterium_AIC <- c(model$aic)
  McFadden<-pR2(model)[4] #pseudoR2
  Cragg_Uhler<-pR2(model)[6]
  ocena <- data.frame(kryterium_AIC, McFadden, Cragg_Uhler)
  return(ocena)
}
#Wywołujemy powyższą funkcję dla modeli
wyniki_oceny_logit <- rbind(
  model_1=ocena_modelu_dwum(logit1),
  model_2=ocena_modelu_dwum(logit2),
  model_3=ocena_modelu_dwum(logit3),
  model_4=ocena_modelu_dwum(logit4),
  model_5=ocena_modelu_dwum(logit5),
  model_6=ocena_modelu_dwum(logit6)
)

wyniki_oceny_logit

#Interpretacja parametrów modelu 6: 
logit6$coefficients
exp(logit6$coefficients)


logit7 <- glm(HeartDisease ~ Age + MaxHR + RestingBP + Sex + ExerciseAngina, data = heart_uczacy, family = binomial)
summary(logit7)
logit8 <- glm(HeartDisease ~ Age + MaxHR + Sex + ExerciseAngina, data = heart_uczacy, family = binomial)
summary(logit8)


#Testy istotności parametrów modelu 8
lrtest(logit8)
waldtest(logit8)

wyniki_oceny_logit <- rbind(
  model_6=ocena_modelu_dwum(logit6),
  model_8=ocena_modelu_dwum(logit8)
)
wyniki_oceny_logit


#MODELE PROBITOWE

#Estymacja modelu dwumianowego probitowego 
probit1 <- glm(HeartDisease ~ Age + Sex + ExerciseAngina + MaxHR, data = heart_uczacy, family = binomial(link=probit))
summary(probit1)

#testy istotności parametrów 

lrtest(probit1)
waldtest(probit1)

wyniki_oceny_logit_probit <- rbind(
  model_logitowy=ocena_modelu_dwum(logit8),
  model_probitowy=ocena_modelu_dwum(probit1)
)
wyniki_oceny_logit_probit



#Kobieta, 65 lat, z dławicą, Tetno 130
#Mężczyzna, 65 lat, z dławicą, Tetno 130``
predict(logit8, data.frame(Age=c(65,65), Sex = c("F","M"), ExerciseAngina= c("Y","Y"), MaxHR= c(130,130)), type= "response")
predict(probit1, data.frame(Age=c(65, 65), Sex = c("F","M"), ExerciseAngina= c("Y","Y"), MaxHR= c(130,130)), type= "response")


#Kobieta, 35 lat, bez dławicy, Tetno 130
#Kobieta, 35 lat, z dławicą, Tetno 130
predict(logit8, data.frame(Age=c(35,35), Sex = c("F","F"), ExerciseAngina= c("N","Y"), MaxHR= c(130,130)), type= "response")
predict(probit1, data.frame(Age=c(35, 35), Sex = c("F","F"), ExerciseAngina= c("N","Y"), MaxHR= c(130,130)), type= "response")

#Kobieta, 65 lat, bez dławicy, Tetno 100
#Mężczyzna, 65 lat, bez dławicy, Tetno 100
predict(logit8, data.frame(Age=c(65,65), Sex = c("F","M"), ExerciseAngina= c("N","N"), MaxHR= c(100,100)), type= "response")
predict(probit1, data.frame(Age=c(65, 65), Sex = c("F","M"), ExerciseAngina= c("N","N"), MaxHR= c(100,100)), type= "response")

#Mężczyzna, 35 lat, z dławicą, tetno 100
#Mężczyzna, 35 lat, bez dławicy, tetno 100
predict(logit8, data.frame(Age=c(35,35), Sex = c("M","M"), ExerciseAngina= c("Y","N"), MaxHR= c(100,100)), type= "response")
predict(probit1, data.frame(Age=c(35, 35), Sex = c("M","M"), ExerciseAngina= c("Y","N"), MaxHR= c(100,100)), type= "response")


#Porównanie jakości predykcji modeli logit1 i probit1
#Tablice trafności dla wybranego punktu odcięcia p*

p <- table(heart_uczacy$HeartDisease)[2]/nrow(heart_uczacy)

cat("Tablica trafności dla modelu logitowego - próba ucząca\n")
tab_traf <- data.frame(obserwowane=logit8$y, przewidywane=ifelse(logit8$fitted.values>p, 1, 0))
table(tab_traf)

cat("Tablica trafności dla modelu probitowego - próba ucząca\n")
tab_traf <- data.frame(obserwowane=probit1$y, przewidywane=ifelse(probit1$fitted.values>p, 1, 0))
table(tab_traf)

cat("Tablica trafności dla modelu logitowego - próba testowa\n")
tab_traf <- data.frame(obserwowane=heart_testowy$HeartDisease, przewidywane=ifelse(predict(logit8, heart_testowy, type = "response")>p, 1, 0))
table(tab_traf)

cat("Tablica trafności dla modelu probitowego - próba testowa\n")
tab_traf <- data.frame(obserwowane=heart_testowy$HeartDisease, przewidywane=ifelse(predict(probit1, heart_testowy, type = "response")>p, 1, 0))
table(tab_traf)

miary_pred <- function(model, dane, Y, p = 0.5) {
  tab <- table(obserwowane = Y, przewidywane = ifelse(predict(model, dane, type = "response") > p, 1, 0))
  ACC <- (tab[1,1]+tab[2,2])/sum(tab)
  ER <- (tab[1,2]+tab[2,1])/sum(tab)
  SENS <- (tab[2,2])/(tab[2,1]+tab[2,2])
  SPEC <- (tab[1,1])/(tab[1,1]+tab[1,2])
  PPV <- (tab[2,2])/(tab[1,2]+tab[2,2])
  NPV <- (tab[1,1])/(tab[2,1]+tab[1,1])
  miary <- data.frame(ACC, ER, SENS, SPEC, PPV, NPV)
  return(miary)
}

wyniki_miary_pred <- rbind(
  model_logit_uczacy = miary_pred(model = logit8, dane = heart_uczacy,  Y = heart_uczacy$HeartDisease, p), 
  model_probit_uczacy = miary_pred(model = probit1, dane = heart_uczacy, Y = heart_uczacy$HeartDisease,  p),
  model_logit_testowy = miary_pred(model = logit8, dane = heart_testowy,  Y = heart_testowy$HeartDisease, p), 
  model_probit_testowy = miary_pred(model = probit1, dane = heart_testowy, Y = heart_testowy$HeartDisease,  p))
wyniki_miary_pred

#Krzywa ROC

#krzywa czerwona - ROC wyznaczona na zbiorze uczącym
#krzywa niebieska - ROC wyznaczona na zbiorze testowym

par(mfrow=c(1,2))
rocobj1 <- roc(logit8$y, logit8$fitted.values)
rocobj1_t <- roc(heart_testowy$HeartDisease, predict(logit8, heart_testowy, type = "response"))
plot(rocobj1, main = "Krzywe ROC dla modelu logitowego", col="red")
lines(rocobj1_t, col="blue")

rocobj2 <- roc(probit1$y, probit1$fitted.values)
rocobj2_t <- roc(heart_testowy$HeartDisease, predict(probit1, heart_testowy, type = "response"))
plot(rocobj2, main = "Krzywe ROC dla modelu probitowego", col="red")
lines(rocobj2_t, col="blue")


#AUC - pole powierzchni pod krzywą ROC

#dla zbioru uczącego
auc(logit8$y, logit8$fitted.values)
auc(probit1$y, probit1$fitted.values)


#dla zbioru testowego
auc(heart_testowy$HeartDisease, predict(logit8, heart_testowy, type = "response"))
auc(heart_testowy$HeartDisease, predict(probit1, heart_testowy, type = "response"))

miary_pred <- function(model, dane, Y, p = 0.5) {
  tab <- table(obserwowane = Y, przewidywane = ifelse(predict(model, dane, type = "response") > p, 1, 0))
  ACC <- (tab[1,1]+tab[2,2])/sum(tab)
  ER <- (tab[1,2]+tab[2,1])/sum(tab)
  SENS <-tab[2,2]/((tab[2,1]+tab[2,2]))
  SPEC <-tab[1,1]/((tab[1,2]+tab[1,1]))
  PPV<-tab[2,2]/((tab[2,2]+tab[1,2]))
  NPV<-tab[1,1]/((tab[2,1]+tab[1,1]))
  AUC<- auc(model$y, model$fitted.values)
  miary <- data.frame(AUC, ACC, ER, SENS, SPEC, PPV, NPV)
  return(miary)
}

wyniki_miary_pred <- rbind(
  model_logit_testowy = miary_pred(model = logit8, dane = heart_testowy,  Y = heart_testowy$HeartDisease, p), 
  model_probit_testowy = miary_pred(model = probit1, dane = heart_testowy, Y = heart_testowy$HeartDisease,  p))
wyniki_miary_pred

p1 <- p
cat("Punkt odcięcia jako proporcja z próby uczącej p*=", p1, "\n")
p2 <- coords(rocobj1, "best", ret="threshold", best.method = "youden", transpose = TRUE)
cat("Punkt odcięcia według indeksu Youdena dla próby uczącej p*=", p2, "\n")

cat("\nPorównanie miar jakości predykcji dla dwóch punktów odcięcia \n")
coords(rocobj1, p1, ret = c("threshold", "acc", "sens", "spec", "ppv", "npv", "youden"), transpose = TRUE)
coords(rocobj1, "best", ret = c("threshold", "acc", "sens", "spec", "ppv", "npv", "youden"),best.method = "youden", transpose = TRUE)

