# ==========================================
# ETAPA 1: Construcción
# ==========================================
FROM maven:3.9.9-eclipse-temurin-21-alpine AS builder

WORKDIR /build

# Copia configuración de dependencias 
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copia código fuente y empaqueta el jar
COPY src ./src
RUN mvn clean package -DskipTests

# ==========================================
# ETAPA 2: Ejecución ligera 
# ==========================================
FROM eclipse-temurin:25-jre-alpine

WORKDIR /app

# Crear un usuario sin privilegios root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copia .jar generado
COPY --from=builder /build/target/cl-matiivilla-vehiculos-0.0.1-SNAPSHOT.jar app.jar

# Asignacion permisos al usuario no-root
RUN chown -R appuser:appgroup /app
USER appuser

# Puerto ms-vehiculos
EXPOSE 9004

# Parametros JVM optimizados para contenedores
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]