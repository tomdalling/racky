module LitmalSchemaDSL
  def uploaded_file
    Hash(
      filename: _String,
      type: _String,
      tempfile: anything,
    )
  end
end

RSchema::DefaultDSL.include(LitmalSchemaDSL)
