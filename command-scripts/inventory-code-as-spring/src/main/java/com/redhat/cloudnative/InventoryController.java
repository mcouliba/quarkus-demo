package com.redhat.cloudnative;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(value = "/api/inventory")
public class InventoryController {
    @Autowired
    private InventoryRepository repository;

    @ResponseBody
    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public Iterable<Inventory> getAll() {
        return repository.findAll();
    }

    @ResponseBody
    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    @RequestMapping(value = "/{itemId}")
    public Inventory getAvailability(@PathVariable("itemId") String itemId) {
        Inventory inventory = repository.findById(itemId).get();
        return inventory;
    }
}