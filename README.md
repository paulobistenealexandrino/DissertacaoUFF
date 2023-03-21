# Dissertação PPGE-UFF

<!-- badges: start -->
<!-- badges: end -->

Esse é o repositório da minha dissertação para o Programa de Pós-graduação em Economia da Universidade Federal Fluminense.

## Estrutura do Diretório

.
├── DissertacaoUFF.Rproj
├── input
│   ├── data_processed
│   │   └── landuse_rio.RDS
│   └── data_raw
│       ├── r5r
│       │   ├── destiny_points.csv
│       │   ├── gtfs_rio-de-janeiro.zip
│       │   ├── Malha_Viária_Rio_de_Janeiro.osm.pbf
│       │   └── origin_points.csv
│       └── shapefiles
│           ├── Limites_Rio_de_Janeiro
│           │   ├── Limites_Rio_de_Janeiro.cpg
│           │   ├── Limites_Rio_de_Janeiro.dbf
│           │   ├── Limites_Rio_de_Janeiro.prj
│           │   ├── Limites_Rio_de_Janeiro.shp
│           │   └── Limites_Rio_de_Janeiro.shx
│           ├── Trajetos_BRT
│           │   ├── Trajetos_BRT.cpg
│           │   ├── Trajetos_BRT.dbf
│           │   ├── Trajetos_BRT.prj
│           │   ├── Trajetos_BRT.shp
│           │   ├── Trajetos_BRT.shx
│           │   └── Trajetos_BRT.xml
│           ├── Trajetos_Onibus
│           │   ├── Trajetos_Onibus.cpg
│           │   ├── Trajetos_Onibus.dbf
│           │   ├── Trajetos_Onibus.prj
│           │   ├── Trajetos_Onibus.shp
│           │   ├── Trajetos_Onibus.shx
│           │   └── Trajetos_Onibus.xml
│           ├── Trajetos_Trem
│           │   ├── Trajetos_Trem.cpg
│           │   ├── Trajetos_Trem.dbf
│           │   ├── Trajetos_Trem.prj
│           │   ├── Trajetos_Trem.shp
│           │   ├── Trajetos_Trem.shx
│           │   └── Trajetos_Trem.xml
│           └── Trajetos_VLT
│               ├── Trajetos_VLT.cpg
│               ├── Trajetos_VLT.dbf
│               ├── Trajetos_VLT.prj
│               ├── Trajetos_VLT.shp
│               ├── Trajetos_VLT.shx
│               └── Trajetos_VLT.xml
├── LICENSE.md
├── output
├── README.md
├── scripts
│   ├── 00_setup.R
│   ├── 01.1_cleaning_landuse.R
│   └── 01.2_cleaning_routing.R
└── temp
    └── mapa_transportes.R