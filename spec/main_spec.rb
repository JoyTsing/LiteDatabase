describe 'database' do

  def run_script(commands)
    raw_output=nil
    IO.popen("./db","r+") do |pipe|
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
    expect(result[-2]).to eq('Error: Table full.')
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
end
