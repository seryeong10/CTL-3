package com.baeumpay.backend.setting.service;

import com.baeumpay.backend.setting.dto.UserSettingResponse;
import com.baeumpay.backend.setting.dto.UserSettingUpdateRequest;
import com.baeumpay.backend.setting.entity.UserSetting;
import com.baeumpay.backend.setting.repository.UserSettingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserSettingService {

    private final UserSettingRepository userSettingRepository;

    @Transactional
    public UserSettingResponse getSetting(
            Long userId
    ) {

        UserSetting setting =
                userSettingRepository.findByUserId(userId)
                        .orElseGet(() ->
                                userSettingRepository.save(
                                        new UserSetting(userId)
                                )
                        );

        return UserSettingResponse.from(setting);
    }

    @Transactional
    public UserSettingResponse updateSetting(
            Long userId,
            UserSettingUpdateRequest request
    ) {

        UserSetting setting =
                userSettingRepository.findByUserId(userId)
                        .orElseGet(() ->
                                userSettingRepository.save(
                                        new UserSetting(userId)
                                )
                        );

        setting.update(
                request.notificationEnabled(),
                request.largeTextEnabled()
        );

        return UserSettingResponse.from(setting);
    }
}