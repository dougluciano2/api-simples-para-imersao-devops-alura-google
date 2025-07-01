package br.com.dougluciano.api.teste.imersaoaluragoogle.controller;

import br.com.dougluciano.api.teste.imersaoaluragoogle.model.Person;
import br.com.dougluciano.api.teste.imersaoaluragoogle.service.PersonService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/persons")
public class PersonController {

    @Autowired
    private PersonService service;

    @GetMapping
    public List<Person> findAll(){
        return service.findAll();
    }

    @GetMapping("/{id}")
    public Person findById(@PathVariable Long id){
        return service.findById(id);
    }

    @PostMapping
    public void save(@RequestBody Person person){
        service.create(person);
    }

    @PutMapping("/{id}")
    public void update(@PathVariable Long id, @RequestBody Person person){
        service.update(id, person);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id){
        service.delete(id);
    }
}
