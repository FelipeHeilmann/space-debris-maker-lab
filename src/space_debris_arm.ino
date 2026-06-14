#include <Servo.h>

// ── Pinos ──────────────────────────────────────────────────
const int PINO_SERVO1    = 9;
const int PINO_SERVO2    = 10;
const int PINO_LED_VERDE = 6;
const int PINO_LED_VERM  = 7;

// ── Ângulos predefinidos ────────────────────────────────────
const int BRACO_CIMA    = 90;
const int BRACO_BAIXO   =  0;
const int GARRA_ABERTA  = 180;
const int GARRA_FECHADA = 45;

// ── Objetos Servo ───────────────────────────────────────────
Servo servo1;
Servo servo2;

// ── Estado global ──────────────────────────────────────────
int  anguloBraco = BRACO_BAIXO;
int  anguloGarra = GARRA_ABERTA;
bool sistemaOK   = true;

// ── Protótipos ─────────────────────────────────────────────
void moverBraco(int angulo);
void moverGarra(int angulo);
void piscaLED(int pino, int vezes, int intervalo);
void imprimirStatus();
void verificarSistema();
void inicializarPosicao();

// ===========================================================
void setup() {
  Serial.begin(9600);

  pinMode(PINO_LED_VERDE, OUTPUT);
  pinMode(PINO_LED_VERM,  OUTPUT);

  servo1.attach(PINO_SERVO1);
  servo2.attach(PINO_SERVO2);

  inicializarPosicao();

  piscaLED(PINO_LED_VERDE, 3, 150);
  digitalWrite(PINO_LED_VERDE, HIGH);

  Serial.println(F("============================================"));
  Serial.println(F("  SPACE DEBRIS CAPTURE ARM - v1.0.0"));
  Serial.println(F("  Sistema inicializado com sucesso!"));
  Serial.println(F("============================================"));
  Serial.println(F("Comandos:"));
  Serial.println(F("  U -> Braco sobe  (90 graus)"));
  Serial.println(F("  D -> Braco desce  (0 graus)"));
  Serial.println(F("  O -> Garra abre (180 graus)"));
  Serial.println(F("  C -> Garra fecha (45 graus) - CAPTURA"));
  Serial.println(F("  S -> Status do sistema"));
  Serial.println(F("============================================"));
}

// ===========================================================
void loop() {
  verificarSistema();

  if (Serial.available() > 0) {
    char cmd = Serial.read();

    if (cmd == '\r' || cmd == '\n' || cmd == ' ') return;

    cmd = toupper(cmd);

    Serial.print(F("[CMD] Recebido: "));
    Serial.println(cmd);

    switch (cmd) {
      case 'U':
        Serial.println(F(">> BRACO: subindo para 90 graus..."));
        moverBraco(BRACO_CIMA);
        Serial.println(F("   [OK] Braco posicionado em CIMA."));
        break;

      case 'D':
        Serial.println(F(">> BRACO: descendo para 0 graus..."));
        moverBraco(BRACO_BAIXO);
        Serial.println(F("   [OK] Braco posicionado em BAIXO."));
        break;

      case 'O':
        Serial.println(F(">> GARRA: abrindo para 180 graus..."));
        moverGarra(GARRA_ABERTA);
        Serial.println(F("   [OK] Garra ABERTA. Pronta para captura."));
        break;

      case 'C':
        Serial.println(F(">> GARRA: fechando para 45 graus..."));
        moverGarra(GARRA_FECHADA);
        Serial.println(F("   [OK] Detrito CAPTURADO! Garra fechada."));
        piscaLED(PINO_LED_VERDE, 2, 100);
        digitalWrite(PINO_LED_VERDE, HIGH);
        break;

      case 'S':
        Serial.println(F(">> STATUS: consultando sistema..."));
        piscaLED(PINO_LED_VERDE, 3, 200);
        digitalWrite(PINO_LED_VERDE, HIGH);
        imprimirStatus();
        break;

      default:
        Serial.print(F("[ERRO] Comando '"));
        Serial.print(cmd);
        Serial.println(F("' nao reconhecido. Use: U, D, O, C ou S"));
        piscaLED(PINO_LED_VERM, 1, 300);
        if (sistemaOK) digitalWrite(PINO_LED_VERDE, HIGH);
        break;
    }

    Serial.println();
  }
}

// ===========================================================
void moverBraco(int angulo) {
  int passo = (angulo > anguloBraco) ? 1 : -1;
  while (anguloBraco != angulo) {
    anguloBraco += passo;
    servo1.write(anguloBraco);
    delay(12);
  }
}

// ===========================================================
void moverGarra(int angulo) {
  int passo = (angulo > anguloGarra) ? 1 : -1;
  while (anguloGarra != angulo) {
    anguloGarra += passo;
    servo2.write(anguloGarra);
    delay(10);
  }
}

// ===========================================================
void piscaLED(int pino, int vezes, int intervalo) {
  for (int i = 0; i < vezes; i++) {
    digitalWrite(pino, HIGH);
    delay(intervalo);
    digitalWrite(pino, LOW);
    delay(intervalo);
  }
}

// ===========================================================
void imprimirStatus() {
  Serial.println(F("--------------------------------------------"));
  Serial.println(F("  RELATORIO DE STATUS - CAPTURE ARM"));
  Serial.println(F("--------------------------------------------"));

  Serial.print(F("  Sistema      : "));
  Serial.println(sistemaOK ? F("OPERACIONAL") : F("FALHA"));

  Serial.print(F("  Servo1 (Braco): "));
  Serial.print(anguloBraco);
  Serial.print(F(" graus -> "));
  Serial.println(anguloBraco >= 45 ? F("CIMA") : F("BAIXO"));

  Serial.print(F("  Servo2 (Garra): "));
  Serial.print(anguloGarra);
  Serial.print(F(" graus -> "));
  Serial.println(anguloGarra > 90 ? F("ABERTA") : F("FECHADA"));

  Serial.print(F("  LED Verde    : "));
  Serial.println(digitalRead(PINO_LED_VERDE) ? F("ACESO") : F("APAGADO"));

  Serial.print(F("  Uptime       : "));
  Serial.print(millis() / 1000);
  Serial.println(F(" s"));

  Serial.println(F("--------------------------------------------"));
}

// ===========================================================
void verificarSistema() {
  static unsigned long ultimaVerificacao = 0;
  unsigned long agora = millis();

  if (agora - ultimaVerificacao >= 5000) {
    ultimaVerificacao = agora;

    bool angOK = (anguloBraco >= 0 && anguloBraco <= 180) &&
    (anguloGarra  >= 0 && anguloGarra  <= 180);

    sistemaOK = angOK;

    if (sistemaOK) {
      digitalWrite(PINO_LED_VERDE, HIGH);
      digitalWrite(PINO_LED_VERM,  LOW);
    } else {
      digitalWrite(PINO_LED_VERDE, LOW);
      digitalWrite(PINO_LED_VERM,  HIGH);
      Serial.println(F("[ALERTA] Falha detectada no sistema!"));
    }
  }
}

// ===========================================================
void inicializarPosicao() {
  anguloBraco = BRACO_BAIXO;
  anguloGarra = GARRA_FECHADA;
  servo1.write(anguloBraco);
  servo2.write(anguloGarra);
  delay(500);
}
