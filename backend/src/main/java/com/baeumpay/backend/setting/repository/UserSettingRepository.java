package com.baeumpay.backend.setting.repository;

import com.baeumpay.backend.setting.entity.UserSetting;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserSettingRepository
        extends JpaRepository<UserSetting, Long> {

    Optional<UserSetting> findByUserId(
            Long userId
    );
}