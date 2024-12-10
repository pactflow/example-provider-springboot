package com.example.springboot;

import lombok.Data;

import jakarta.persistence.*;

import com.fasterxml.jackson.annotation.JsonFormat;

@Data
@Entity
class Product {
  @JsonFormat( shape = JsonFormat.Shape.STRING)
  private @Id Long id;
  private String name;
  private String version;

  Product() {}

  Product(Long id, String name,  String version) {
    this.id = id;
    this.name = name;
    this.version = version;
  }
}