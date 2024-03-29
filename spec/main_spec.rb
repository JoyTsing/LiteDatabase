describe 'database' do
  before do
    `rm -rf test.db`
  end


  def run_script(commands)
    raw_output=nil
    IO.popen("./db test.db","r+") do |pipe|
      commands.each do |command|
        pipe.puts command
      end

      pipe.close_write

      raw_output=pipe.gets(nil)
    end
    raw_output.split("\n")
  end

  it 'inserts and retrieves a row' do
    result = run_script([
      "insert 1 user1 person1@ex.com",
      "select",
      ".exit",
    ])
    expect(result).to match_array([
      "Executed.",
      "(1, user1, person1@ex.com)",
      "Executed.",
      ".exit",
    ])
  end

  it 'prints error message when table is full' do
    script=(1..1401).map do |i|
      "insert #{i} user#{i} person#{i}@example.com"
    end
    script<<".exit"
    result=run_script(script)
    expect(result[-2]).to match_array([
      "Executed.",
      "Need to implement splitting internal node",
    ])
  end

  it 'allows inserting strings that are the maximum length' do
    long_username="a"*32
    long_email="a"*255
    script=[
      "insert 1 #{long_username} #{long_email}",
      "select",
      ".exit",
    ]
    result=run_script(script)
    expect(result).to match_array([
      "Executed.",
      "(1, #{long_username}, #{long_email})",
      "Executed.",
      ".exit",
    ])
  end

  it 'prints error message if strings are too long' do
    long_username="a"*33
    long_email="a"*256
    script=[
      "insert 1 #{long_username} #{long_email}",
      "select",
      ".exit",
    ]
    result=run_script(script)
    expect(result).to match_array([
      "String is too long.",
      "Executed.",
      ".exit",
    ])
  end

  it 'prints an error message if id is negative' do
    script=["insert -1 sdasd foo@bar.com",
    "select",
    ".exit",
    ]
    result=run_script(script)
    expect(result).to match_array([
      "ID must be positive.",
      "Executed.",
      ".exit",
    ])
  end

  it 'keeps data after closing connection' do
    result=run_script([
      "insert 1 user1 person1@example.com",
      ".exit",
    ])
    expect(result).to match_array([
      "Executed.",
      ".exit",
    ])
    result2=run_script([
      "select",
      ".exit",
    ])
    expect(result2).to match_array([
      "(1, user1, person1@example.com)",
      "Executed.",
      ".exit",
    ])
  end

  it 'prints constants' do
    script =[
      ".constants",
      ".exit",
    ]
    result=run_script(script)

    expect(result).to match_array([
      ".constants",
      "Constants:",
      "ROW_SIZE: 293",
      "COMMON_NODE_HEADER_SIZE: 6",
      "LEAF_NODE_HEADER_SIZE: 10",
      "LEAF_NODE_CELL_SIZE: 297",
      "LEAF_NODE_SPACE_FOR_CELLS: 4086",
      "LEAF_NODE_MAX_CELLS: 13",
      ".exit",
    ])
  end

  it 'allows printing out the structure of a one-node btree' do
    script =[3,1,2].map do |i|
      "insert #{i} user#{i} person#{i}@example.com"
    end
    script << ".btree"
    script << ".exit"
    result = run_script(script)

    expect(result).to match_array([
      ".btree",
      "Executed.",
      "Executed.",
      "Executed.",
      "Tree:",
      "- leaf (size 3)",
      "  - 1",
      "  - 2",
      "  - 3",
      ".exit"
    ])
  end

  it 'prints an error message if there is a duplicate id' do
    script=[
      "insert 1 user1 person1@example.com",
      "insert 1 user1 person1@example.com",
      "select",
      ".exit",
    ]
    result=run_script(script)
    expect(result).to match_array([
      "Executed.",
      "Error: Duplicate key.",
      "(1, user1, person1@example.com)",
      "Executed.",
      ".exit"
    ])
  end

  it 'allows printing out the structure of a 3-leaf-node btree' do
    script=(1..14).map do |i|
      "insert #{i} user#{i} person#{i}@example.com"
    end
    script<<".btree"
    script<<"insert 15 user15 person15@example.com"
    script<<".exit"
    result =run_script(script)

    expect(result[14...(result.length)]).to match_array([
      ".btree",
      "Tree:",
      "- internal (size 1)",
      "  - leaf (size 7)",
      "    - 1",
      "    - 2",
      "    - 3",
      "    - 4",
      "    - 5",
      "    - 6",
      "    - 7",
      "  - key 7",
      "  - leaf (size 7)",
      "    - 8",
      "    - 9",
      "    - 10",
      "    - 11",
      "    - 12",
      "    - 13",
      "    - 14",
      "Need to implement searching an internal node",
      ".exit",
    ])
  end

end
