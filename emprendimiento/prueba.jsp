<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Página de Prueba - Avícola El Pollo Feliz</title>
    <!-- Enlace a la hoja de estilos externa de la prueba -->
    <link rel="stylesheet" href="estilosPrueba.css">
</head>

<body>

    <!-- Banner con fondo #1e293b, texto blanco y centrado -->
    <header class="banner-principal">
        <img src="imagenes/00d3ceb9-f4c3-409a-920b-4a2d7e0e7be2.jpg" alt="Logo Avícola" class="logo-empresa">
        <h1 class="titulo-banner">Página de Prueba (prueba.jsp)</h1>
        <p class="subtitulo-banner">Demostración de navegación hipertextual y arquitectura semántica W3C/WHATWG</p>
    </header>

    <!-- Menú semántico con aislamiento de navegación -->
    <nav class="navegacion-principal">
        <ul class="lista-navegacion">
            <li class="item-nav"><a href="index.html" class="nav-enlace">← Regresar a la Tienda (index.html)</a></li>
            <li class="item-nav"><a href="prueba.jsp" class="nav-enlace activo tab-prueba">Prueba</a></li>
        </ul>
    </nav>

    <!-- Contenido principal de la página de prueba -->
    <div class="contenedor-principal">
        <main class="catalogo-productos">
            <header class="catalogo-encabezado">
                <h2 class="titulo-catalogo">Módulo de Integración JSP</h2>
                <p class="subtitulo-catalogo">Esta vista certifica el enlace exitoso desde el archivo central index.html.</p>
            </header>

            <article class="card-producto">
                <header class="card-header">
                    <span class="badge-3d">✨ Conexión Exitosa</span>
                    <h3 class="nombre-producto">Validación del Enlace JSP</h3>
                </header>
                <figure class="figura-producto-2d">
                    <img src="imagenes/pollo.jpg" alt="Confirmación de prueba" class="img-producto-2d">
                    <figcaption class="caption-2d">Estado: Conectado correctamente</figcaption>
                </figure>
                <p class="descripcion-producto">
                    El enlace hipertextual configurado en el menú &lt;nav&gt; de index.html apunta a esta página prueba.jsp de manera impecable, cumpliendo con la estructura de navegación e-commerce solicitada.
                </p>
                <section class="precios-producto">
                    <p class="precio-unitario">
                        <span class="etiqueta-precio">Servidor:</span>
                        <strong class="valor-precio">JSP / Java Web</strong>
                    </p>
                    <p class="precio-mayor">
                        <span class="etiqueta-precio">Estado:</span>
                        <strong class="valor-precio">200 OK</strong>
                    </p>
                </section>
                <p class="enlace-volver-contenedor">
                    <a href="index.html" class="enlace-volver">← Volver al Catálogo de Productos</a>
                </p>
            </article>
        </main>
    </div>

    <!-- Pie de página con fondo #1e293b, texto blanco y centrado -->
    <footer class="pie-pagina">
        <p>&copy; 2026 Jhoel Rios - Avícola El Pollo Feliz | Todos los derechos reservados</p>
        <p>Entorno de prueba JSP activo</p>
    </footer>

</body>

</html>

