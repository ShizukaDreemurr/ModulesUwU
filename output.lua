local bit32_bxor = bit32.bxor
local bit32_rshift = bit32.rshift
local bit32_lshift = bit32.lshift
local bit32_rrotate = bit32.rrotate
local bit32_lrotate = bit32.lrotate

local common_W = {}
local K_lo_modulo, hi_factor = 4294967296, 0
local TWO_POW_NEG_56 = 1.3877787807814457e-17
local TWO56_POW_7 = 256 ^ 7

local function sha512_feed_128(H_lo, H_hi, str, offs, size)
    local W, K_lo, K_hi = common_W, sha2_K_lo, sha2_K_hi
    local h1_lo, h2_lo, h3_lo, h4_lo, h5_lo, h6_lo, h7_lo, h8_lo = H_lo[1], H_lo[2], H_lo[3], H_lo[4], H_lo[5], H_lo[6], H_lo[7], H_lo[8]
    local h1_hi, h2_hi, h3_hi, h4_hi, h5_hi, h6_hi, h7_hi, h8_hi = H_hi[1], H_hi[2], H_hi[3], H_hi[4], H_hi[5], H_hi[6], H_hi[7], H_hi[8]
    for pos = offs, offs + size - 1, 128 do
        for j = 1, 32 do
            pos = pos + 4
            local a, b, c, d = string.byte(str, pos - 3, pos)
            W[j] = ((a * 256 + b) * 256 + c) * 256 + d
        end
        for jj = 34, 160, 2 do
            local a_lo, a_hi, b_lo, b_hi = W[jj - 30], W[jj - 31], W[jj - 4], W[jj - 5]
            local tmp1 = bit32_bxor(bit32_rshift(a_lo, 1) + bit32_lshift(a_hi, 31), bit32_rshift(a_lo, 8) + bit32_lshift(a_hi, 24), bit32_rshift(a_lo, 7) + bit32_lshift(a_hi, 25)) % 4294967296 + bit32_bxor(bit32_rshift(b_lo, 19) + bit32_lshift(b_hi, 13), bit32_lshift(b_lo, 3) + bit32_rshift(b_hi, 29), bit32_rshift(b_lo, 6) + bit32_lshift(b_hi, 26)) % 4294967296 + W[jj - 14] + W[jj - 32]
            local tmp2 = tmp1 % 4294967296
            W[jj - 1] = bit32_bxor(bit32_rshift(a_hi, 1) + bit32_lshift(a_lo, 31), bit32_rshift(a_hi, 8) + bit32_lshift(a_lo, 24), bit32_rshift(a_hi, 7)) + bit32_bxor(bit32_rshift(b_hi, 19) + bit32_lshift(b_lo, 13), bit32_lshift(b_hi, 3) + bit32_rshift(b_lo, 29), bit32_rshift(b_hi, 6)) + W[jj - 15] + W[jj - 33] + (tmp1 - tmp2) / 4294967296
            W[jj] = tmp2
        end
        local a_lo, b_lo, c_lo, d_lo, e_lo, f_lo, g_lo, h_lo = h1_lo, h2_lo, h3_lo, h4_lo, h5_lo, h6_lo, h7_lo, h8_lo
        local a_hi, b_hi, c_hi, d_hi, e_hi, f_hi, g_hi, h_hi = h1_hi, h2_hi, h3_hi, h4_hi, h5_hi, h6_hi, h7_hi, h8_hi
        for j = 1, 80 do
            local jj = 2 * j
            local tmp1 = bit32_bxor(bit32_rshift(e_lo, 14) + bit32_lshift(e_hi, 18), bit32_rshift(e_lo, 18) + bit32_lshift(e_hi, 14), bit32_lshift(e_lo, 23) + bit32_rshift(e_hi, 9)) % 4294967296 + (bit32_band(e_lo, f_lo) + bit32_band(-1 - e_lo, g_lo)) % 4294967296 + h_lo + K_lo[j] + W[jj]
            local z_lo = tmp1 % 4294967296
            local z_hi = bit32_bxor(bit32_rshift(e_hi, 14) + bit32_lshift(e_lo, 18), bit32_rshift(e_hi, 18) + bit32_lshift(e_lo, 14), bit32_lshift(e_hi, 23) + bit32_rshift(e_lo, 9)) + bit32_band(e_hi, f_hi) + bit32_band(-1 - e_hi, g_hi) + h_hi + K_hi[j] + W[jj - 1] + (tmp1 - z_lo) / 4294967296
            h_lo = g_lo
            h_hi = g_hi
            g_lo = f_lo
            g_hi = f_hi
            f_lo = e_lo
            f_hi = e_hi
            tmp1 = z_lo + d_lo
            e_lo = tmp1 % 4294967296
            e_hi = z_hi + d_hi + (tmp1 - e_lo) / 4294967296
            d_lo = c_lo
            d_hi = c_hi
            c_lo = b_lo
            c_hi = b_hi
            b_lo = a_lo
            b_hi = a_hi
            tmp1 = z_lo + (bit32_band(d_lo, c_lo) + bit32_band(b_lo, bit32_bxor(d_lo, c_lo))) % 4294967296 + bit32_bxor(bit32_rshift(b_lo, 28) + bit32_lshift(b_hi, 4), bit32_lshift(b_lo, 30) + bit32_rshift(b_hi, 2), bit32_lshift(b_lo, 25) + bit32_rshift(b_hi, 7)) % 4294967296
            a_lo = tmp1 % 4294967296
            a_hi = z_hi + (bit32_band(d_hi, c_hi) + bit32_band(b_hi, bit32_bxor(d_hi, c_hi))) + bit32_bxor(bit32_rshift(b_hi, 28) + bit32_lshift(b_lo, 4), bit32_lshift(b_hi, 30) + bit32_rshift(b_lo, 2), bit32_lshift(b_hi, 25) + bit32_rshift(b_lo, 7)) + (tmp1 - a_lo) / 4294967296
        end
        a_lo = h1_lo + a_lo
        h1_lo = a_lo % 4294967296
        h1_hi = (h1_hi + a_hi + (a_lo - h1_lo) / 4294967296) % 4294967296
        a_lo = h2_lo + b_lo
        h2_lo = a_lo % 4294967296
        h2_hi = (h2_hi + b_hi + (a_lo - h2_lo) / 4294967296) % 4294967296
        a_lo = h3_lo + c_lo
        h3_lo = a_lo % 4294967296
        h3_hi = (h3_hi + c_hi + (a_lo - h3_lo) / 4294967296) % 4294967296
        a_lo = h4_lo + d_lo
        h4_lo = a_lo % 4294967296
        h4_hi = (h4_hi + d_hi + (a_lo - h4_lo) / 4294967296) % 4294967296
        a_lo = h5_lo + e_lo
        h5_lo = a_lo % 4294967296
        h5_hi = (h5_hi + e_hi + (a_lo - h5_lo) / 4294967296) % 4294967296
        a_lo = h6_lo + f_lo
        h6_lo = a_lo % 4294967296
        h6_hi = (h6_hi + f_hi + (a_lo - h6_lo) / 4294967296) % 4294967296
        a_lo = h7_lo + g_lo
        h7_lo = a_lo % 4294967296
        h7_hi = (h7_hi + g_hi + (a_lo - h7_lo) / 4294967296) % 4294967296
        a_lo = h8_lo + h_lo
        h8_lo = a_lo % 4294967296
        h8_hi = (h8_hi + h_hi + (a_lo - h8_lo) / 4294967296) % 4294967296
    end
    H_lo[1], H_lo[2], H_lo[3], H_lo[4], H_lo[5], H_lo[6], H_lo[7], H_lo[8] = h1_lo, h2_lo, h3_lo, h4_lo, h5_lo, h6_lo, h7_lo, h8_lo
    H_hi[1], H_hi[2], H_hi[3], H_hi[4], H_hi[5], H_hi[6], H_hi[7], H_hi[8] = h1_hi, h2_hi, h3_hi, h4_hi, h5_hi, h6_hi, h7_hi, h8_hi
end

local function sha512ext(width, message)
    local length, tail, H_lo, H_hi = 0, "", table.pack(table.unpack(sha2_H_ext512_lo[width])), table.pack(table.unpack(sha2_H_ext512_hi[width]))
    local function partial(message_part)
        if message_part then
            local partLength = #message_part
            if tail then
                length = length + partLength
                local offs = 0
                if tail ~= "" and #tail + partLength >= 128 then
                    offs = 128 - #tail
                    sha512_feed_128(H_lo, H_hi, tail .. string.sub(message_part, 1, offs), 0, 128)
                    tail = ""
                end
                local size = partLength - offs
                local size_tail = size % 128
                sha512_feed_128(H_lo, H_hi, message_part, offs, size - size_tail)
                tail = tail .. string.sub(message_part, partLength + 1 - size_tail)
                return partial
            else
                error("Adding more chunks is not allowed after receiving the result", 2)
            end
        else
            if tail then
                local final_blocks = table.create(3)
                final_blocks[1] = tail
                final_blocks[2] = "\128"
                final_blocks[3] = string.rep("\0", (-17 - length) % 128 + 9)
                tail = nil
                length = length * (8 / TWO56_POW_7)
                for j = 4, 10 do
                    length = length % 1 * 256
                    final_blocks[j] = string.char(math.floor(length))
                end
                final_blocks = table.concat(final_blocks)
                sha512_feed_128(H_lo, H_hi, final_blocks, 0, #final_blocks)
                local max_reg = math.ceil(width / 64)
                for j = 1, max_reg do
                    H_lo[j] = string.format("%08x", H_hi[j] % 4294967296) .. string.format("%08x", H_lo[j] % 4294967296)
                end
                H_hi = nil
                H_lo = string.sub(table.concat(H_lo, "", 1, max_reg), 1, width / 4)
            end
            return H_lo
        end
    end
    if message then
        return partial(message)()
    else
        return partial
    end
end

return function(message)
    return sha512ext(384, message)
end