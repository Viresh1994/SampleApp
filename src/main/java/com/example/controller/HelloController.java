package com.example.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {
	@GetMapping("/")
    public String index() {
        return "Hello World!";
    }

    @GetMapping("/api/hello")
    public String helo() {
        return "Hello Java!";
    }

    @GetMapping("/api/hello")
    public String home() {
        return "Hello Java Home!";
    }
}
