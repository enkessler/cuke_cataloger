def with_captured_stderr
  old_stderr = $stderr
  old_stderr_const = STDERR

  captured = nil

  begin
    $stderr = StringIO.new('','w')
    yield
    captured = $stderr.string
  ensure
    $stderr = old_stderr
     STDERR = old_stderr_const
  end

  captured
end

def with_captured_stdout
  old_stdout = $stdout
  captured = nil

  begin
    $stdout = StringIO.new('','w')
    yield
  captured =  $stdout.string
  ensure
    $stdout = old_stdout
  end

  captured
end
