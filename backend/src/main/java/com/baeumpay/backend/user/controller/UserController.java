package com.baeumpay.backend.user.controller;

import com.baeumpay.backend.user.dto.UserCreateRequest;
import com.baeumpay.backend.user.dto.UserResponse;
import com.baeumpay.backend.user.entity.UserType;
import com.baeumpay.backend.user.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    @PostMapping
    public UserResponse createUser(@Valid @RequestBody UserCreateRequest request) {
        return userService.createUser(request);
    }

    @GetMapping
    public List<UserResponse> getUsers(
            @RequestParam(required = false) UserType userType
    ) {
        return userService.getUsers(userType);
    }

    @GetMapping("/{userId}")
    public UserResponse getUser(@PathVariable Long userId) {
        return userService.getUser(userId);
    }

    @GetMapping("/phone/{phone}")
    public UserResponse getUserByPhone(@PathVariable String phone) {
        return userService.getUserByPhone(phone);
    }
}
