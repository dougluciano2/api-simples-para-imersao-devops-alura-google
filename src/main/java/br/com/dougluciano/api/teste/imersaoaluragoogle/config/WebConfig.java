package br.com.dougluciano.api.teste.imersaoaluragoogle.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**") // Aplica a regra a todos os endpoints da sua API
                .allowedOrigins("*") // Permite requisições de qualquer origem (site)
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS", "HEAD", "TRACE", "CONNECT") // Permite todos os métodos HTTP
                .allowedHeaders("*"); // Permite todos os cabeçalhos (headers) na requisição
    }
}