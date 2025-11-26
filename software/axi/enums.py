from enum import Enum

class MemOp(int, Enum):
    IDLE = 0
    WRITE = 1
    READ = 2

class MemSize(int, Enum):
    BYTE = 0
    HALF = 1
    WORD = 2
    DWORD = 3

    @staticmethod
    def from_bit_count(bit_count: int) -> 'MemSize':
        bits_to_size = {
            8: MemSize.BYTE,
            16: MemSize.HALF,
            32: MemSize.WORD,
            64: MemSize.DWORD,
        }
        return bits_to_size[bit_count]

class MemOpStatus(str, Enum):
    NONE = 'none'
    DONE = 'done'
    WAIT = 'wait'
    ERROR = 'error'
    INVALID = 'invalid'

    @staticmethod
    def from_reg(status_reg: int) -> 'MemOpStatus':
        if (status_reg >> 3) & 0x1:
            return MemOpStatus.INVALID
        elif (status_reg >> 2) & 0x1:
            return MemOpStatus.ERROR
        elif (status_reg >> 1) & 0x1:
            return MemOpStatus.DONE
        elif status_reg & 0x1:
            return MemOpStatus.WAIT
        else:
            return MemOpStatus.NONE

class MemOpResult:
    def __init__(self, status: MemOpStatus, data: int, latency: int) -> None:
        self.status = status
        self.data = data
        self.latency = latency
