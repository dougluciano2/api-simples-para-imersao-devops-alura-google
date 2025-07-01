package br.com.dougluciano.api.teste.imersaoaluragoogle.repository;

import br.com.dougluciano.api.teste.imersaoaluragoogle.model.Person;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PersonRepository extends JpaRepository<Person, Long> {
}
