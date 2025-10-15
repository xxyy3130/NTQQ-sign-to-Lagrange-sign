#!/usr/bin/env python3
"""
提取 wrapper.node 指定偏移处的特征码
"""

import sys

def extract_signature(file_path, offset, length=32):
    """
    从文件中提取特征码
    
    Args:
        file_path: wrapper.node 文件路径
        offset: 偏移地址（十六进制，如 0xA996E0）
        length: 提取的字节数，默认 32
    """
    try:
        with open(file_path, 'rb') as f:
            # 跳转到偏移位置
            f.seek(offset)
            # 读取指定长度的字节
            bytes_data = f.read(length)
            
            # 转换为十六进制字符串
            hex_string = ' '.join(f'{b:02X}' for b in bytes_data)
            
            print(f"文件: {file_path}")
            print(f"偏移: 0x{offset:X}")
            print(f"长度: {length} 字节")
            print(f"\n特征码 (前 {length} 字节):")
            print(hex_string)
            print()
            
            # 分段显示（每 16 字节一行）
            print("分段显示:")
            for i in range(0, len(bytes_data), 16):
                chunk = bytes_data[i:i+16]
                hex_chunk = ' '.join(f'{b:02X}' for b in chunk)
                print(f"  {hex_chunk}")
            
            # 推荐用于搜索的长度
            print(f"\n推荐搜索长度 (前 15 字节):")
            short_sig = ' '.join(f'{b:02X}' for b in bytes_data[:15])
            print(f"  {short_sig}")
            
            return hex_string
            
    except FileNotFoundError:
        print(f"错误: 文件不存在: {file_path}")
        return None
    except Exception as e:
        print(f"错误: {e}")
        return None

if __name__ == "__main__":
    # 示例用法
    examples = [
        {
            "name": "9.9.12-25493",
            "path": r"C:\Users\admin\Documents\qqnt\9912\resources\app\versions\9.9.12-25493\wrapper.node",
            "offset": 0xA996E0
        },
        {
            "name": "9.9.21-38711",
            "path": r"C:\Users\admin\Documents\qqnt\9921\versions\9.9.21-38711\resources\app\wrapper.node",
            "offset": 0xA996E0  # 待查找，先尝试相同偏移
        }
    ]
    
    if len(sys.argv) > 1:
        # 命令行模式
        file_path = sys.argv[1]
        offset = int(sys.argv[2], 16) if len(sys.argv) > 2 else 0xA996E0
        length = int(sys.argv[3]) if len(sys.argv) > 3 else 32
        
        extract_signature(file_path, offset, length)
    else:
        # 批量处理示例
        print("=" * 70)
        print("批量提取特征码")
        print("=" * 70)
        print()
        
        for example in examples:
            print(f"\n{'='*70}")
            print(f"版本: {example['name']}")
            print(f"{'='*70}")
            extract_signature(example['path'], example['offset'])
            print()
        
        print("\n" + "="*70)
        print("使用方法:")
        print("  python extract_signature.py <文件路径> <偏移值(十六进制)> [长度]")
        print("\n示例:")
        print('  python extract_signature.py "path\\to\\wrapper.node" A996E0 32')
        print("="*70)
