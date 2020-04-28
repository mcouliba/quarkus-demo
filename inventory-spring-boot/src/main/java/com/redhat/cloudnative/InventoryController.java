package com.redhat.cloudnative;



import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

@Controller
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