// ============================================================
//  SPACE DEBRIS CAPTURE GRIP  —  Garra de Dois Dedos
//  Project-Based Maker Lab (PBML) · Global Solution 2026
//  Braco Robotico de Coleta de Amostras (Docking & Retrieval)
// ============================================================
//  Garra de captura para manipulacao de carga em microgravidade.
//  Acionada por 1 servo SG90 (9g) alojado no corpo central.
//  100% parametrico — ajuste os valores na secao PARAMETROS.
//
//  Exportar STL:  OpenSCAD -> F6 (render) -> File > Export > Export as STL
//  Autor: Equipe GS 2026
// ============================================================

/* =================== PARAMETROS PRINCIPAIS =================== */
// ----- Garras (dedos) -----
comp_dedo      = 50;    // [mm] comprimento de cada garra
larg_base_dedo = 11;    // [mm] largura da garra junto ao pivo (hub)
larg_ponta     = 4.5;   // [mm] largura na ponta (afinamento)
esp_dedo       = 9;     // [mm] espessura da garra (ao longo do pino)
folga_pontas   = 1.6;   // [mm] meia-folga entre as pontas quando fechada
ang_abertura   = 24;    // [graus] abertura de cada dedo (0 = fechada)

// ----- Preensao (face interna) -----
n_dentes       = 7;     // numero de dentes de preensao
prof_dente     = 1.9;   // [mm] profundidade de cada dente
pad_ponta      = true;  // almofada antiderrapante na ponta

// ----- Reforco estrutural -----
nervura        = true;  // nervura/coluna de reforco no dorso
alt_nervura    = 2.4;   // [mm] altura da nervura

/* =================== CORPO / SERVO SG90 ===================== */
parede         = 2.6;   // [mm] espessura de parede do corpo
sg90           = [23.2, 12.4, 22.8]; // [mm] caixa do servo SG90
sg90_aba_x     = 4.8;   // [mm] saliencia das abas de fixacao
furo_m2        = 2.2;   // [mm] furos dos parafusos M2 das abas
dist_furos     = 28;    // [mm] distancia entre os furos das abas
canal_cabo     = 5;     // [mm] diametro do canal de passagem do cabo
pino_pivo      = 3.2;   // [mm] diametro do pino de articulacao
folga          = 0.4;   // [mm] folga de montagem do servo

/* =================== QUALIDADE DE RENDER ==================== */
$fn = 72;

/* ============ VALORES DERIVADOS (nao alterar) ============== */
corpo_x  = sg90[0] + 2*parede;
corpo_y  = sg90[1] + 2*parede;
corpo_z  = sg90[2] + parede;
pivo_off = corpo_x/2 - parede - larg_base_dedo/2 + 1.5;       // pivo dos dedos
curva    = pivo_off - folga_pontas;                          // hook ate o centro
seg      = 30;                                               // suavidade do arco

// ============================================================
//                      MONTAGEM FINAL
// ============================================================
module garra_completa() {
    corpo_central();
    // dedo DIREITO
    translate([ pivo_off, 0, corpo_z-1.5]) rotate([0,  ang_abertura, 0]) dedo_garra();
    // dedo ESQUERDO (espelhado -> faces dentadas voltadas ao centro)
    mirror([1,0,0])
    translate([ pivo_off, 0, corpo_z-1.5]) rotate([0,  ang_abertura, 0]) dedo_garra();
}

// ============================================================
//   CORPO CENTRAL  —  aloja o servo SG90; topo recebe os hubs
// ============================================================
module corpo_central() {
    difference() {
        union() {
            r = 3;
            // bloco principal arredondado
            hull() for (sx=[-1,1], sy=[-1,1])
                translate([sx*(corpo_x/2 - r), sy*(corpo_y/2 - r), 0])
                    cylinder(r=r, h=corpo_z, $fn=40);
            // ombro superior (knuckle) onde os dedos se fundem
            translate([0,0,corpo_z-2])
                hull() for (sx=[-1,1])
                    translate([sx*pivo_off,0,0]) cylinder(d=larg_base_dedo+3, h=3, $fn=48);
            // abas de fixacao do servo
            for (sx=[-1,1])
                translate([sx*corpo_x/2, -corpo_y/2, 0])
                    cube([sg90_aba_x, corpo_y, parede*1.6]);
        }
        // cavidade do servo (aberta no topo)
        translate([0,0,parede + (sg90[2]+2)/2 - 0.001])
            cube([sg90[0]+folga, sg90[1]+folga, sg90[2]+2], center=true);
        // furos M2 das abas
        for (sx=[-1,1])
            translate([sx*dist_furos/2, 0, -1]) cylinder(d=furo_m2, h=parede*4, $fn=24);
        // janela de saida do horn do servo
        translate([0,0,corpo_z-3]) cube([sg90[0]*0.45, sg90[1]+folga, 8], center=true);
        // canal de cabo
        translate([0, corpo_y/2, corpo_z*0.4]) rotate([90,0,0])
            cylinder(d=canal_cabo, h=parede*3, center=true, $fn=24);
        // furos dos pinos de pivo (eixo Y, atravessam os hubs)
        for (sx=[-1,1])
            translate([sx*pivo_off, corpo_y, corpo_z-1.5]) rotate([90,0,0])
                cylinder(d=pino_pivo, h=corpo_y*2, center=true, $fn=30);
    }
}

// ============================================================
//   DEDO / GARRA  —  claw curvo: dentes internos + nervura + gancho
//   Canonico: hub na origem (eixo do pino = Y); sobe em +Z e
//   curva a ponta para -X (gancho voltado ao centro).
// ============================================================
function dx(t) = -curva * pow(t, 1.6);                 // curvatura (gancho)
function dz(t) = comp_dedo * t;                        // sobe
function dr(t) = (larg_base_dedo*(1-t) + larg_ponta*t)/2; // afina

module dedo_garra() {
    difference() {
        union() {
            corpo_dedo();
            cubo_dedo();
            if (nervura)  nervura_dorso();
            dentes_preensao();
            if (pad_ponta) almofada_ponta();
        }
        // furo do pino de articulacao
        rotate([90,0,0]) cylinder(d=pino_pivo, h=esp_dedo*3, center=true, $fn=30);
        // furo de ligacao ao horn do servo
        translate([-larg_base_dedo*0.12, 0, comp_dedo*0.18]) rotate([90,0,0])
            cylinder(d=2.2, h=esp_dedo*3, center=true, $fn=24);
    }
}

// corpo curvo: cadeia de cilindros (eixo Y) em hull -> claw chato e suave
module corpo_dedo() {
    for (i=[0:seg-1]) {
        t0=i/seg; t1=(i+1)/seg;
        hull() {
            translate([dx(t0),0,dz(t0)]) rotate([90,0,0]) cylinder(r=dr(t0), h=esp_dedo, center=true, $fn=44);
            translate([dx(t1),0,dz(t1)]) rotate([90,0,0]) cylinder(r=dr(t1), h=esp_dedo, center=true, $fn=44);
        }
    }
    translate([dx(1),0,dz(1)]) rotate([90,0,0]) cylinder(r=larg_ponta/2, h=esp_dedo, center=true, $fn=44);
}

// hub solido do pivo
module cubo_dedo() {
    rotate([90,0,0]) cylinder(d=larg_base_dedo, h=esp_dedo, center=true, $fn=48);
}

// dentes de preensao na face interna (lado -X = voltado ao centro)
module dentes_preensao() {
    for (i=[0:n_dentes-1]) {
        t = 0.30 + 0.60*i/(n_dentes-1);
        cx=dx(t); cz=dz(t); rr=dr(t);
        translate([cx - rr + 0.3, 0, cz]) rotate([0,-90,0])
            cylinder(r1=0.2, r2=prof_dente, h=prof_dente, center=false, $fn=8);
    }
}

// nervura de reforco no dorso (lado +X = convexo)
module nervura_dorso() {
    for (i=[0:seg-1]) {
        t0=i/seg; t1=(i+1)/seg;
        if (t0>0.10 && t1<0.94)
        hull() {
            translate([dx(t0)+dr(t0)-0.4,0,dz(t0)]) cube([alt_nervura, esp_dedo*0.5, 0.1], center=true);
            translate([dx(t1)+dr(t1)-0.4,0,dz(t1)]) cube([alt_nervura, esp_dedo*0.5, 0.1], center=true);
        }
    }
}

// almofada antiderrapante (lado interno da ponta)
module almofada_ponta() {
    t=0.965;
    translate([dx(t)-dr(t)*0.3,0,dz(t)]) scale([0.8,1,1]) rotate([90,0,0])
        cylinder(r=1.7, h=esp_dedo*0.72, center=true, $fn=24);
}

// ============================================================
//                       RENDERIZAR
// ============================================================
garra_completa();
// Para exportar/ver so 1 dedo:  comente acima e use ->  dedo_garra();
