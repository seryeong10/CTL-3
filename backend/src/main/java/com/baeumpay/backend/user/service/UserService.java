package com.baeumpay.backend.user.service;

import com.baeumpay.backend.point.service.PointService;
import com.baeumpay.backend.user.dto.UserCreateRequest;
import com.baeumpay.backend.user.dto.UserResponse;
import com.baeumpay.backend.user.entity.User;
import com.baeumpay.backend.user.entity.UserType;
import com.baeumpay.backend.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserService {

    private final UserRepository userRepository;
    private final PointService pointService;

    @Transactional
    public UserResponse createUser(UserCreateRequest request) {
        if (request.phone() != null && userRepository.findByPhone(request.phone()).isPresent()) {
            throw new IllegalArgumentException("이미 등록된 전화번호입니다.");
        }

        User user = new User(
                request.name(),
                request.phone(),
                request.birthYear(),
                request.userType()
        );

        User savedUser = userRepository.save(user);

        // 형 Python 코드의 사용자 등록 시 point_wallets 자동 생성 로직 이관
        pointService.createWallet(savedUser.getUserId());

        return UserResponse.from(savedUser);
    }

    public User getUserEntity(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));
    }

    public UserResponse getUser(Long userId) {
        return UserResponse.from(getUserEntity(userId));
    }

    public UserResponse getUserByPhone(String phone) {
        User user = userRepository.findByPhone(phone)
                .orElseThrow(() -> new IllegalArgumentException("해당 연락처의 사용자를 찾을 수 없습니다."));
        return UserResponse.from(user);
    }

    public List<UserResponse> getUsers(UserType userType) {
        List<User> users = userType == null
                ? userRepository.findAllByOrderByCreatedAtDesc()
                : userRepository.findByUserTypeOrderByCreatedAtDesc(userType);

        return users.stream()
                .map(UserResponse::from)
                .toList();
    }
}
