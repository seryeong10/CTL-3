package com.baeumpay.backend.toucherror.controller;

import com.baeumpay.backend.toucherror.dto.TouchErrorLogCreateRequest;
import com.baeumpay.backend.toucherror.dto.TouchErrorLogResponse;
import com.baeumpay.backend.toucherror.service.TouchErrorLogService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/touch-errors")
public class TouchErrorLogController {

    private final TouchErrorLogService touchErrorLogService;

    @PostMapping("/users/{userId}")
    public TouchErrorLogResponse createTouchErrorLog(
            @PathVariable Long userId,
            @Valid @RequestBody TouchErrorLogCreateRequest request
    ) {
        return touchErrorLogService.createTouchErrorLog(userId, request);
    }

    @GetMapping("/users/{userId}")
    public List<TouchErrorLogResponse> getUserErrorLogs(@PathVariable Long userId) {
        return touchErrorLogService.getUserErrorLogs(userId);
    }
}
