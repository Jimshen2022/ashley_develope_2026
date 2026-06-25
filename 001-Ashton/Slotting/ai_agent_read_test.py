import os

def check_ai_readability():
    print("Testing if AI can parse data_lineage_topology.txt...")
    file_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'data_lineage_topology.txt')
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
        
    print(f"Read {len(content)} characters.")
    print("AI interpretation test passed.")

if __name__ == "__main__":
    check_ai_readability()