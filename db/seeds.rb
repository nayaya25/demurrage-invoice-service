# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# db/seeds.rb

# Clear existing data
puts "Clearing existing data..."
RefundRequest.delete_all
Invoice.delete_all
BillOfLanding.delete_all
Customer.delete_all

# Create customers
puts "Creating customers..."
customers = []

customers << Customer.create!(
  name: "ACME Shipping Corp",
  code: "ACME001",
  nom_groupe: "ACME Group",
  paie_caution: true,
  status: "ACTIVE",
  priority: false
)

customers << Customer.create!(
  name: "Global Logistics Ltd",
  code: "GLOB002",
  nom_groupe: "Global Group",
  paie_caution: true,
  status: "ACTIVE",
  priority: true
)

customers << Customer.create!(
  name: "Maritime Express SA",
  code: "MARI003",
  nom_groupe: "Maritime Group",
  paie_caution: false,
  status: "ACTIVE",
  priority: false
)

puts "Created #{customers.count} customers"

# Create Bill of Landings with different scenarios
puts "Creating Bill of Landings..."

# Scenario 1: BLs that become overdue TODAY (for invoice generation testing)
bl_overdue_today = BillOfLanding.create!(
  number: "BL0001234",
  arrival_date: Date.current - 8.days,  # Arrived 7 days ago
  freetime: 7,                          # 7 days free time = expires TODAY
  vessel_name: "MV Atlantic",
  consignee_name: "ACME Shipping Corp",
  containers_20ft_dry: 2,
  containers_40ft_dry: 1,
  containers_20ft_reefer: 0,
  containers_40ft_reefer: 1,
  containers_20ft_special: 0,
  containers_40ft_special: 0,
  exempted: false,
  is_valid: 1,
  status: "VALIDATED",
  customer: customers[0]
)

bl_overdue_today_2 = BillOfLanding.create!(
  number: "BL0002345",
  arrival_date: Date.current - 6.days,  # Arrived 6 days ago
  freetime: 5,                          # 5 days free time = expires TODAY
  vessel_name: "MV Pacific",
  consignee_name: "Global Logistics Ltd",
  containers_20ft_dry: 3,
  containers_40ft_dry: 2,
  containers_20ft_reefer: 1,
  containers_40ft_reefer: 0,
  containers_20ft_special: 0,
  containers_40ft_special: 0,
  exempted: false,
  is_valid: 1,
  status: "VALIDATED",
  customer: customers[1]
)

# Scenario 2: BLs already overdue (expired yesterday or before)
bl_already_overdue = BillOfLanding.create!(
  number: "BL0003456",
  arrival_date: Date.current - 10.days, # Arrived 10 days ago
  freetime: 5,                          # 5 days free time = expired 5 days ago
  vessel_name: "MV Indian Ocean",
  consignee_name: "Maritime Express SA",
  containers_20ft_dry: 1,
  containers_40ft_dry: 1,
  containers_20ft_reefer: 0,
  containers_40ft_reefer: 0,
  containers_20ft_special: 1,
  containers_40ft_special: 0,
  exempted: false,
  is_valid: 1,
  status: "VALIDATED",
  customer: customers[2]
)

# Scenario 3: BLs not yet overdue (still in free time)
bl_not_overdue = BillOfLanding.create!(
  number: "BL0004567",
  arrival_date: Date.current - 2.days,  # Arrived 2 days ago
  freetime: 7,                          # 7 days free time = expires in 5 days
  vessel_name: "MV Arctic",
  consignee_name: "ACME Shipping Corp",
  containers_20ft_dry: 2,
  containers_40ft_dry: 0,
  containers_20ft_reefer: 1,
  containers_40ft_reefer: 1,
  containers_20ft_special: 0,
  containers_40ft_special: 0,
  exempted: false,
  is_valid: 1,
  status: "VALIDATED",
  customer: customers[0]
)

# Scenario 4: Exempted BL (should not generate invoices)
bl_exempted = BillOfLanding.create!(
  number: "BL0005678",
  arrival_date: Date.current - 10.days,
  freetime: 3,                          # Should be overdue but exempted
  vessel_name: "MV Antarctic",
  consignee_name: "Global Logistics Ltd",
  containers_20ft_dry: 1,
  containers_40ft_dry: 1,
  containers_20ft_reefer: 0,
  containers_40ft_reefer: 0,
  containers_20ft_special: 0,
  containers_40ft_special: 0,
  exempted: true,                       # EXEMPTED - should skip
  is_valid: 1,
  status: "VALIDATED",
  customer: customers[1]
)

# Scenario 5: BL with existing invoice (should not generate duplicate)
bl_with_invoice = BillOfLanding.create!(
  number: "BL0006789",
  arrival_date: Date.current - 8.days,
  freetime: 3,                          # Already overdue
  vessel_name: "MV Southern",
  consignee_name: "Maritime Express SA",
  containers_20ft_dry: 2,
  containers_40ft_dry: 1,
  containers_20ft_reefer: 0,
  containers_40ft_reefer: 0,
  containers_20ft_special: 0,
  containers_40ft_special: 0,
  exempted: false,
  is_valid: 1,
  status: "VALIDATED",
  customer: customers[2]
)

puts "Created 6 Bill of Landings with different scenarios"

# Create existing invoice for testing duplicate prevention
puts "Creating existing invoices..."
Invoice.create!(
  reference: "DEM0001",
  bl_number: bl_with_invoice.number,
  customer_code: bl_with_invoice.customer.code,
  customer_name: bl_with_invoice.customer.name,
  amount: 240.0,  # 3 containers * 80 USD
  currency: "USD",
  status: "OPEN",
  issued_date: Date.current - 2.days,
  user_id: 1
)

puts "Created 1 existing invoice"

# Create some refund requests
puts "Creating refund requests..."
RefundRequest.create!(
  bl_number: bl_already_overdue.number,
  amount_requested: "500.00",
  status: "PENDING",
  forwarder_id: 1,
  request_date: Date.current - 1.day
)

puts "Created 1 refund request"

puts "\n=== SEED DATA SUMMARY ==="
puts "Customers: #{Customer.count}"
puts "Bill of Landings: #{BillOfLanding.count}"
puts "  - Becoming overdue today: #{BillOfLanding.where("DATE(arrival_date + INTERVAL freetime DAY) = ?", Date.current).count}"
puts "  - Already overdue: #{BillOfLanding.where("DATE(arrival_date + INTERVAL freetime DAY) < ?", Date.current).count}"
puts "  - Not yet overdue: #{BillOfLanding.where("DATE(arrival_date + INTERVAL freetime DAY) > ?", Date.current).count}"
puts "  - Exempted: #{BillOfLanding.where(exempted: true).count}"
puts "Invoices: #{Invoice.count}"
puts "Refund Requests: #{RefundRequest.count}"

puts "\n=== TEST SCENARIOS ==="
puts "1. Run Demurrage::InvoiceGenerator.call to create invoices for BLs overdue today"
puts "2. Check that exempted BLs and BLs with existing invoices are skipped"
puts "3. Verify invoice amounts: (total_containers * 80 USD)"