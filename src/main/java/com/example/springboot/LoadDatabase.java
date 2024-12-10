package com.example.springboot;

import lombok.extern.slf4j.Slf4j;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@Slf4j
class LoadDatabase {

  @Bean
  CommandLineRunner initDatabase(ProductRepository repository) {
    return args -> {
      log.info("Preloading " + repository.save(new Product(1L, "Burger", "1.0.0")));
      log.info("Preloading " + repository.save(new Product(2L, "Chips", "1.2.3")));
    };
  }
}