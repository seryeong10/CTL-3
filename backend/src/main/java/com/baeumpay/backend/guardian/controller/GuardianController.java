package com.baeumpay.backend.guardian.controller;

import com.baeumpay.backend.guardian.dto.GuardianLinkCreateRequest;
import com.baeumpay.backend.guardian.dto.GuardianLinkResponse;
import com.baeumpay.backend.guardian.dto.GuardianSeniorResponse;
import com.baeumpay.backend.guardian.dto.SeniorGuardianResponse;
import com.baeumpay.backend.guardian.service.GuardianService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/guardians")
public class GuardianController {

    private final GuardianService guardianService;

    @PostMapping("/{guardianUserId}/seniors")
    public GuardianLinkResponse linkSenior(
            @PathVariable Long guardianUserId,
            @Valid @RequestBody GuardianLinkCreateRequest request
    ) {
        return guardianService.linkSenior(guardianUserId, request);
    }

    @GetMapping("/{guardianUserId}/seniors")
    public List<GuardianSeniorResponse> getMySeniors(@PathVariable Long guardianUserId) {
        return guardianService.getMySeniors(guardianUserId);
    }

    @GetMapping("/seniors/{seniorUserId}/guardians")
    public List<SeniorGuardianResponse> getMyGuardians(@PathVariable Long seniorUserId) {
        return guardianService.getMyGuardians(seniorUserId);
    }
}
