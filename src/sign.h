#pragma once

#include <string>
#include <tuple>

namespace Sign
{
    bool Init(const std::string &version, uint64_t customOffset = 0);
    std::tuple<std::string, std::string, std::string> Call(const std::string_view cmd, const std::string_view src, int seq);
}