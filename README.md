# 🛰️ Space Debris Capture Arm
### Sistema de Docking & Retrieval com Arduino + OpenSCAD

[![Arduino](https://img.shields.io/badge/Arduino-Uno-00979D?logo=arduino)](https://www.arduino.cc/)
[![Simulador](https://img.shields.io/badge/Simulador-Wokwi-red)](https://wokwi.com)
[![OpenSCAD](https://img.shields.io/badge/Modelo_3D-OpenSCAD-blue)](https://openscad.org/)
[![Licença](https://img.shields.io/badge/Licença-MIT-green)](LICENSE)

---

## 👥 Participantes

| Nome | RM |
|-------|-------|
| Açussena Macedo Mautone | 552568 |
| Carlos Eduardo Caramante Ribeiro | 552159|
| Felipe Heilmann Marques | 551026 |
| Felipe Voidela Toledo | 98595 |
| Ian Cancian Nachtergaele | 98387 |
---

## 🔗 Links

| Recurso | Link |
|---------|------|
| **Simulador Wokwi** | [Abrir simulação](https://wokwi.com/projects/466815081525804033) |

---

## 📁 Estrutura do Repositório

```
space-debris-arm/
├── src/
│   └── space_debris_arm.ino     ← Código Arduino comentado
├── model/
│   ├── garra_espacial.scad      ← Modelo 3D paramétrico (OpenSCAD)
│   └── garra_espacial.stl       ← Exportação universal para impressão
├── images/
│   ├── circuito.png       ← Print do circuito simulado
│   └── garra.png         ← Render do modelo 3D
└── README.md                    ← Este arquivo
```

---

## ⚡ Componentes do Circuito

| Componente | Quantidade | Função |
|-----------|-----------|--------|
| Arduino Uno | 1 | Placa de desenvolvimento |
| Servo SG90 (9g) | 2 | Servo1: base/rotação · Servo2: garra |
| LED Verde (5mm) | 1 | Indica sistema operacional |
| LED Vermelho (5mm) | 1 | Indica falha do sistema |
| Resistor 220Ω | 2 | Proteção dos LEDs |
| Fonte bancada | 1 | 5V ou 6V para os servos |
| Protoboard | 1 | Para encaixar as peças |

### Pinagem

| Pino Arduino | Componente | Descrição |
|-------------|-----------|-----------|
| D9 | Servo1 (Sinal) | Controle da base/rotação |
| D10 | Servo2 (Sinal) | Controle da garra |
| D6 | LED Verde (+) | Status operacional |
| D7 | LED Vermelho (+) | Status de falha |
| 5V | Servos (VCC) | Alimentação |
| GND | Todos | Terra comum |

---

## 🎮 Comandos via Monitor Serial

> **Configuração:** 9600 baud · Enviar como texto simples

| Comando | Tecla | Ação | Ângulo |
|---------|-------|------|--------|
| **Up** | `U` | Braço sobe | Servo1 → **90°** |
| **Down** | `D` | Braço desce | Servo1 → **0°** |
| **Open** | `O` | Garra abre | Servo2 → **180°** |
| **Close** | `C` | Garra fecha / **captura detrito** | Servo2 → **45°** |
| **Status** | `S` | LED pisca 3× + relatório serial | — |

### Exemplo de Sessão Serial

```
============================================
  SPACE DEBRIS CAPTURE ARM - v1.0.0
  Sistema inicializado com sucesso!
============================================

[CMD] Recebido: U
>> BRACO: subindo para 90 graus...
   [OK] Braco posicionado em CIMA.

[CMD] Recebido: C
>> GARRA: fechando para 45 graus...
   [OK] Detrito CAPTURADO! Garra fechada.

[CMD] Recebido: S
>> STATUS: consultando sistema...
--------------------------------------------
  RELATORIO DE STATUS - CAPTURE ARM
--------------------------------------------
  Sistema      : OPERACIONAL
  Servo1 (Braco): 90 graus -> CIMA
  Servo2 (Garra): 45 graus -> FECHADA
  LED Verde    : ACESO
  Uptime       : 12 s
--------------------------------------------

---

## 📜 Licença

MIT License – Livre para uso educacional e projetos pessoais.

---

*Space Debris Capture Arm – Contribuindo para a limpeza orbital* 🌍
