package br.com.dougluciano.api.teste.imersaoaluragoogle.service;

import br.com.dougluciano.api.teste.imersaoaluragoogle.model.Person;
import br.com.dougluciano.api.teste.imersaoaluragoogle.repository.PersonRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.crossstore.ChangeSetPersister;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PersonService {

    @Autowired
    private PersonRepository repository;

    public List<Person> findAll(){
        return repository.findAll();
    }

    public Person findById(Long id){
        return repository.findById(id).orElseThrow();
    }



    public void create(Person person){
        repository.save(person);
    }

    public void update(Long id, Person person){
        repository.save(person);
    }

    public void delete(Long id){
        Person delete = repository.findById(id).orElseThrow();
        repository.delete(delete);
    }
}
