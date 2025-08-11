class ApplicationPayroll
  def calculate
    raise NotImplementedError, "Subclasses must implement calculate method"
  end
end