import time

def run(dfs):
    print("Executing a13_cubes_unique_item...")
    start_time = time.time()
    
    if 'ItemBalance_by_Pieces_Data' in dfs:
        df_pieces = dfs['ItemBalance_by_Pieces_Data']
        # Create a copy for Cubes, preserving only Item and Product columns initially
        # We will calculate cubes for OnHand and Yard, so let's start fresh with Item and Product
        df_cubes = df_pieces[['Item', 'Product']].copy()
        dfs['ItemBalance_by_Cubes_Data'] = df_cubes

    elapsed_time = time.time() - start_time
    print(f"a13_cubes_unique_item completed in {elapsed_time:.2f} seconds.")
