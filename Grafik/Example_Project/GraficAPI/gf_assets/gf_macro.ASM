macro switch value
{
        mov     eax, value
}

macro case label, [value]
{
        cmp     eax, value
        je      label
}

macro memset address, value, count
{
        mov     edi, adress
        mov     eax, value
        mov     ecx, count
        rep     stosb
}

macro memcpy dest, src, count
{
        mov     esim src
        mov     edi, dest
        mov     ecx, count
        rep     movsb
}

macro malloc size
{
        invoke  HeapAlloc, [hHeap], ebx, size
}

macro malloc count, size
{
        invoke  HeapAlloc, [hHeap], 8, count * size
}