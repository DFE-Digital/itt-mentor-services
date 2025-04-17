class UniqueIdentifierValidator < ActiveModel::Validator
  def validate(record)
    if record.urn.blank? && record.vendor_number.blank?
      record.errors.add(:base, "A unique reference number (URN) or vendor number is required")
    end
  end
end
