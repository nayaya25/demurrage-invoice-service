## Key Implementation Choices

### 1. Database Modifications

**Foreign Key Constraint Addition**
- Added missing foreign key constraint between `facture.numero_bl` → `bl.numero_bl`
- Applied `latin1_swedish_ci` collation to ensure compatibility with legacy data
- Created unique index on `bl.numero_bl` to support the foreign key

**Column Renaming for Clarity**
The legacy schema used French column names which reduced code readability. Key translations:

| French (Legacy) | English (New) | Rationale |
|----------------|---------------|-----------|
| `numero_bl` | `number` | Core business identifier |
| `nbre_*pieds_*` | `containers_*ft_*` | Container count fields |
| `statut` | `status` | Universal status field |
| `montant_facture` | `amount` | Invoice amount |
| `code_client` | `customer_code` | Customer identification |

**Why this approach:**
- Improves developer experience and code maintainability
- Maintains backward compatibility through migration rollbacks
- Follows Rails naming conventions

### 2. Domain Model Design

**ActiveRecord Models Structure:**
```
BillOfLanding (bl table)
├── belongs_to :customer
├── has_many :invoices
└── has_many :refund_requests

Customer (client table)
├── has_many :bill_of_landings
└── has_many :invoices (through bill_of_landings)

Invoice (facture table)
├── belongs_to :bill_of_landing
└── has_one :customer (through bill_of_landing)

RefundRequest (remboursement table)
├── belongs_to :bill_of_landing
└── has_one :customer (through bill_of_landing)
```

**Key Business Logic Methods:**

- `BillOfLanding#total_containers` - Sums all container types for pricing
- `BillOfLanding#overdue_as_of?` - Determines if BL is overdue on a given date
- `BillOfLanding#days_overdue` - Calculates overdue duration for pricing
- `BillOfLanding#has_open_invoice?` - Prevents duplicate invoice generation

### 3. Service Object Architecture

**Demurrage::InvoiceGenerator**
- Main orchestrator following Single Responsibility Principle
- Finds BLs that became overdue specifically "today" (not historically overdue)
- Delegates invoice creation to specialized interactor

**Demurrage::BlInvoiceCreatorInteractor**
- Handles individual invoice creation logic
- Applies flat rate pricing: **$80 USD per container per day**
- Generates unique reference numbers with date-based format: `RF{YYMMDD}{HEX}`

**Demurrage::OverdueInvoicesFetcherInteractor**
- Simple query object for fetching open invoices
- Follows consistent interactor pattern

**Why this pattern:**
- Separates business logic from controllers and models
- Enables easy testing and reusability
- Follows Rails service object conventions

### 4. Pricing Strategy

**Flat Rate Model:** $80 USD per container per day
- Simplified pricing structure
- Applied uniformly across all container types (20ft, 40ft, dry, reefer, special)

**Container Calculation:**
```ruby
def total_containers
  [
    containers_20ft_dry, containers_40ft_dry,
    containers_20ft_reefer, containers_40ft_reefer,
    containers_20ft_special, containers_40ft_special
  ].compact.sum
end

def days_since_arrival
  return 0 unless arrival_date
  (Date.current - arrival_date.to_date).to_i
end

defaulting_days = [bl.days_since_arrival - bl.freetime, 0].max
expected_amount = bl.total_containers * defaulting_days * 80.0
```

### 5. Business Rules Implementation

**Invoice Generation Safeguards:**
- Skip BLs that already have open invoices (`has_open_invoice?`)
- Skip BLs with pending refund requests (`has_pending_refund?`)
- Skip exempt BLs (`exempted: true`)
- Only process validated BLs (`is_valid: 1`)

**Overdue Detection Logic:**
```ruby
def self.overdue_today
  today = Date.current
  joins(:customer)
    .where("DATE(arrival_date + INTERVAL freetime DAY) < ?", today)
    .where(exempted: false, is_valid: 1)
    .includes(:customer, :invoices)
end
```

### 6. Data Integrity & Validation

**Model Validations:**
- BL numbers must not exceed 9 characters (legacy requirement)
- All container counts validated as non-negative integers
- Invoice amounts must be positive
- Reference numbers must be unique

**Database Constraints:**
- Foreign key constraints ensure referential integrity
- Unique indexes prevent duplicate BL numbers
- NOT NULL constraints on critical business fields

## Testing Strategy

The application includes comprehensive test coverage for:

- **Model Validations:** Ensuring data integrity rules
- **Associations:** Verifying proper ActiveRecord relationships
- **Business Logic:** Testing overdue calculations and invoice generation
- **API Endpoints:** Request specs for the invoice generation endpoint

## Production Considerations

### Performance
- Database indexes on frequently queried columns (`numero_bl`, `status`)
- Includes associations in queries to prevent N+1 problems
- Batch processing with `find_each` for large datasets

### Monitoring
- Structured JSON responses with timestamps for API calls
- Error handling with appropriate HTTP status codes
- Count tracking for invoice generation operations

## License
MIT