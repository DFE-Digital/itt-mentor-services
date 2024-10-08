MoneyRails.configure do |config|
  config.default_currency = :gbp

  config.amount_column = {
    prefix: "",           # column name prefix
    postfix: "_pence",    # column name  postfix
    column_name: nil,     # full column name (overrides prefix, postfix and accessor name)
    type: :integer,       # column type
    present: true,        # column will be created
    null: false,          # other options will be treated as column options
    default: 0,
  }

  config.currency_column = {
    prefix: "",
    postfix: "_currency",
    column_name: nil,
    type: :string,
    present: true,
    null: false,
    default: "GBP",
  }

  config.no_cents_if_whole = false
end

Money.locale_backend = :i18n
Money.rounding_mode = BigDecimal::ROUND_HALF_UP
