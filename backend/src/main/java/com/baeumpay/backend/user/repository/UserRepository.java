package com.baeumpay.backend.user.repository;

import com.baeumpay.backend.user.entity.User;
import com.baeumpay.backend.user.entity.UserType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByPhone(String phone);

    List<User> findByUserTypeOrderByCreatedAtDesc(UserType userType);

    List<User> findAllByOrderByCreatedAtDesc();
}
