# Sistema de Liquidación de Sueldos - Chile

### Descripción

Sistema de API REST desarrollado en Ruby on Rails para calcular liquidaciones de sueldo de empleados en Chile, incluyendo todos los descuentos legales y beneficios correspondientes.

### Problemática

Una pequeña empresa necesita calcular cuánto debe pagar a fin de mes a cada uno de sus empleados y a las entidades correspondientes (AFP, Isapre, SII).

### Objetivo

Desarrollar una API en Ruby on Rails que permita:

- Cargar información de colaboradores
- Calcular liquidaciones de sueldo del mes en curso
- Disponibilizar liquidaciones con montos calculados en formato JSON

## 🧮 Cálculos a implementar

### Haberes Impónibles
- **Sueldo base mensual**: Sueldo pactado
- **Bonos y haberes**: Imponibles y no imponibles
- **Gratificación legal mensual**: Según normativa vigente

### Haberes No Impónibles
- **Movilización**
- **Colación**

### Descuentos Legales
- **AFP**: 10% de la renta imponible (tope: 81.6 UF)
- **Salud** (Fonasa/Isapre): 7% de la renta imponible (tope: 81.6 UF). Colaborador podría tener su propio plan de salud con un monto pactado en UF.
- **Seguro de Cesantía**: 0.6%
- **Impuesto Único de Segunda Categoría**: Aplicación de tabla progresiva

### Otros descuentos
- **Otros descuentos**: Todos aquellos descuentos que no sean "Descuentos Legales".

### Totales
- **Total Haberes**: Suma de todos los haberes imponibles y no imponibles
- **Total Descuentos**: Suma de todos los descuentos legales y voluntarios
- **Liquido**: Monto final a pagar al colaborador.

## 📊 Consideraciones Técnicas

- **Tope imponible**: 81.6 UF para AFP y Salud
- **Gratificación legal**: Tope de 4.75 IMM anuales (1/12 mensual)
- **Cálculos**: Todos en base mensual
- **Variables**: Junio 2025 (UF/UTM)

## ⚠️  Consideraciones de Desarrollo

### Evitar
- Features que no respondan directamente al enunciado
- Over-engineering del prototipo

### Herramientas Adicionales

- Puedes agregar gemas que aporten valor a tu propuesta
- Documenta las decisiones técnicas importantes para discusión posterior

## 📖 API Documentation

El sistema expone dos endpoints principales para la gestión de liquidaciones de sueldo:

### 💾 PUT /api/payrolls/load

Carga la lista de datos de colaboradores en el sistema, reemplazando toda la información existente.

**Parámetros:**

- **Content-Type**: `application/json`
- **Body** _(requerido)_: Lista con los datos de los colaboradores

**Ejemplo de Request:**

**Plan de salud Fonasa no se envía el valor por lo que corresponde al 7%:**

```json
{
    "data": [
        {
            "rut": "18.123.456-7",
            "nombre": "Ana María Rojas",
            "fecha_ingreso": "2023-01-01",
            "sueldo_base_pactado": 1200000,
            "afiliacion_salud": {
            "tipo": "Fonasa"
            },
            "asignaciones": [
            {
                "nombre": "Movilización",
                "tipo": "haber",
                "monto": 80000,
                "imponible": false,
                "tributable": false
            },
            {
                "nombre": "Colación",
                "tipo": "haber",
                "monto": 60000,
                "imponible": false,
                "tributable": false
            },
            {
                "nombre": "Bono Producción",
                "tipo": "haber",
                "monto": 150000,
                "imponible": true,
                "tributable": true
            },
            {
                "nombre": "Anticipo Sueldo",
                "tipo": "descuento",
                "monto": 50000,
                "imponible": false,
                "tributable": false
            }
        ]
    },
    {
                "rut": "19.876.543-2",
                "nombre": "Carlos Soto Pérez",
                "fecha_ingreso": "2024-07-15",
                "sueldo_base_pactado": 950000,  
                "afiliacion_salud": {
                "tipo": "Isapre",
                "plan_uf": 4.5
                },
                "asignaciones": [
                {
                    "nombre": "Movilización Proporcional",
                    "tipo": "haber",
                    "monto": 40000,
                    "imponible": false,
                    "tributable": false
                },
                {
                    "nombre": "Comisión Ventas",
                    "tipo": "haber",
                    "monto": 75000,
                    "imponible": true,
                    "tributable": true
                },
                {
                    "nombre": "Cuota Social",
                    "tipo": "descuento",
                    "monto": 10000,
                    "imponible": false,
                    "tributable": false
                }
            ]
            },
        {
                "rut": "20.345.678-9",
                "nombre": "Elena González Díaz",
                "fecha_ingreso": "2023-03-01",
                "sueldo_base_pactado": 2500000,
                "afiliacion_salud": {
                "tipo": "Fonasa"
                },
                "asignaciones": [
                {
                    "nombre": "Bono por Desempeño",
                    "tipo": "haber",
                    "monto": 300000,
                    "imponible": true,
                    "tributable": true
                },
                {
                    "nombre": "Reembolso Gastos",
                    "tipo": "haber",
                    "monto": 100000,
                    "imponible": false,
                    "tributable": false
                },
                {
                    "nombre": "Préstamo Empresa",
                    "tipo": "descuento",
                    "monto": 50000,
                    "imponible": false,
                    "tributable": false
                }
            ]
        },
        {
                "rut": "21.987.654-0",
                "nombre": "Fernando López Vargas",
                "fecha_ingreso": "2024-06-01",
                "sueldo_base_pactado": 700000,
                "afiliacion_salud": {
                "tipo": "Fonasa"
                },
                "asignaciones": []
            },
            {
                "rut": "17.654.321-K",
                "nombre": "Gabriela Torres Mena",
                "fecha_ingreso": "2023-09-10",
                "sueldo_base_pactado": 1500000,
                "afiliacion_salud": {
                "tipo": "Isapre",
                "plan_uf": 6.0
                },
                "asignaciones": [
                {
                    "nombre": "Aguinaldo Fiestas Patrias",
                    "tipo": "haber",
                    "monto": 100000,
                    "imponible": true,
                    "tributable": true
                },
                {
                    "nombre": "Movilización",
                    "tipo": "haber",
                    "monto": 70000,
                    "imponible": false,
                    "tributable": false
                },
                {
                    "nombre": "Ahorro Voluntario",
                    "tipo": "descuento",
                    "monto": 30000,
                    "imponible": false,
                    "tributable": false
                }
            ]
        }
    ]
}
```

**Respuestas:**

- **200 OK**: Datos registrados correctamente
- **400 Bad Request**: Error en el formato del request o durante la carga

### 📊 POST /api/payrolls/calculate

Calcula las liquidaciones de sueldo para uno o más colaboradores especificados por RUT.

**Parámetros:**

- **Content-Type**: `application/json`
- **Body** _(requerido)_: Lista de RUTs de colaboradores a calcular

**Ejemplo de Request:**

```json
{
    "ruts": [
        "11111111-1",
        "22222222-2"
    ]
}
```

**Respuestas:**

- **200 OK**: Liquidaciones calculadas correctamente en el payload
- **400 Bad Request**: Error en el formato del request o durante el cálculo

## 🏃‍♂️ Uso

### Iniciar el servidor

```bash
bin/rails s
```

### Ejemplos de uso con cURL

**Cargar datos de colaboradores:**

```bash
curl -X PUT http://localhost:3000/api/payrolls/load \
  -H "Content-Type: application/json" \
  -d '{"data": [{"rut": "11111111-1", "wage": 1000000, "items": []}]}'
```

**Calcular liquidaciones:**

```bash
curl -X POST http://localhost:3000/api/payrolls/calculate \
  -H "Content-Type: application/json" \
  -d '{"ruts": ["11111111-1"]}'
```

### Ejecutar Tests

```bash
bin/rails test
```