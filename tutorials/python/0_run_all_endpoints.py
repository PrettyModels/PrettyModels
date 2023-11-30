import os

import ai_return_nowcaster
import cash_flow_terminator
import deal_exit_simulator
import takahashi_alexander

print("--- run all endpoints successfully:")
print(ai_return_nowcaster.model, ai_return_nowcaster.endpoints)
print(cash_flow_terminator.model, cash_flow_terminator.endpoints)
print(deal_exit_simulator.model, deal_exit_simulator.endpoints)
print(takahashi_alexander.model, takahashi_alexander.endpoints)

# Jupyter Notebooks
modules = ["cash_flow_terminator", "deal_exit_simulator"]
for module in modules:
    print("--- execute jupyter notebook:", module)
    cmd = f"jupyter nbconvert --to notebook --execute --inplace jupyter/{module}/{module}.ipynb"
    os.system(cmd)
    print("--- convert jupyter notebook to markdown file:", module)
    os.system(f"jupyter nbconvert --to markdown jupyter/{module}/{module}.ipynb")
    os.system(cmd)


def cleanup():
    # Get the current directory where the Python script is located
    directory_path = os.path.dirname(os.path.abspath(__file__))

    # List all files in the directory
    all_files = os.listdir(directory_path)

    # Filter for .csv files
    csv_files = [file for file in all_files if file.endswith(".csv")]

    # Check if any .csv files were found
    if csv_files:
        # Iterate through the list and delete each .csv file
        for csv_file in csv_files:
            file_path = os.path.join(directory_path, csv_file)
            os.remove(file_path)
            print(f"Deleted file: {file_path}")
    else:
        print("No .csv files found in the directory.")


if __name__ == "__main__":
    cleanup()
