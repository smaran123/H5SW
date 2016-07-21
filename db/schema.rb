# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131210072107) do

  create_table "businesses", :force => true do |t|
    t.string   "biz_type"
    t.integer  "company_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "companies", :force => true do |t|
    t.string   "email",                  :default => "",      :null => false
    t.string   "encrypted_password",     :default => "",      :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "name"
    t.string   "phone_number"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.string   "authentication_token"
    t.string   "access_token"
    t.string   "access_secret"
    t.string   "realm_id"
    t.string   "status",                 :default => "trial"
    t.string   "plan"
    t.string   "stripe_card_token"
    t.string   "no_of_users"
    t.datetime "subscription_date"
    t.datetime "new_company_period"
    t.string   "jobs_remaining"
    t.string   "user_firstname"
    t.string   "user_lastname"
  end

  add_index "companies", ["confirmation_token"], :name => "index_companies_on_confirmation_token", :unique => true
  add_index "companies", ["email"], :name => "index_companies_on_email", :unique => true
  add_index "companies", ["reset_password_token"], :name => "index_companies_on_reset_password_token", :unique => true

  create_table "contacts", :force => true do |t|
    t.string   "business"
    t.string   "email"
    t.string   "mobile"
    t.string   "name"
    t.string   "role"
    t.string   "twitter"
    t.integer  "company_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "jobsite_id"
    t.integer  "customer_id"
  end

  create_table "customers", :force => true do |t|
    t.string   "types"
    t.string   "company_name"
    t.integer  "company_id"
    t.string   "parent_billing"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.text     "contact"
    t.string   "website"
    t.string   "business_type"
    t.string   "terms_client"
    t.string   "status",                :default => "Active"
    t.string   "account"
    t.string   "phone"
    t.string   "action"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.integer  "contact_id"
    t.integer  "jobsite_id"
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "gmaps",                 :default => false
    t.integer  "quickbook_customer_id"
  end

  create_table "customs", :force => true do |t|
    t.string   "name"
    t.string   "field"
    t.integer  "company_id"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.string   "cus_type"
    t.integer  "position"
    t.integer  "tab_id"
    t.boolean  "status",     :default => true
    t.string   "drop_value"
  end

  create_table "documents", :force => true do |t|
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.integer  "documentable_id"
    t.string   "documentable_type"
    t.string   "description"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.integer  "company_id"
    t.integer  "jobsite_id"
  end

  create_table "dropdown_values", :force => true do |t|
    t.text     "drop_value"
    t.integer  "custom_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "company_id"
    t.integer  "customer_id"
    t.integer  "jobsite_id"
    t.integer  "job_id"
  end

  create_table "inventories", :force => true do |t|
    t.string   "itemtype"
    t.string   "qty"
    t.string   "number"
    t.string   "name"
    t.text     "description"
    t.decimal  "unit_cost"
    t.decimal  "unit_price"
    t.decimal  "subtotal"
    t.integer  "company_id"
    t.integer  "customer_id"
    t.integer  "jobsite_id"
    t.integer  "job_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "items", :force => true do |t|
    t.string   "itemtype"
    t.string   "qty"
    t.string   "number"
    t.string   "name"
    t.text     "description"
    t.decimal  "unit_cost"
    t.decimal  "unit_price"
    t.string   "job_item"
    t.integer  "company_id"
    t.integer  "customer_id"
    t.integer  "jobsite_id"
    t.integer  "job_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "quickbook_item_id"
  end

  create_table "jobs", :force => true do |t|
    t.string   "reference_no",                                         :default => "",  :null => false
    t.datetime "due_date"
    t.string   "class_type",                                           :default => "",  :null => false
    t.string   "assigned_to",                                          :default => "",  :null => false
    t.string   "status",                                               :default => "",  :null => false
    t.string   "sales_person",                                         :default => "",  :null => false
    t.string   "summary"
    t.decimal  "sub_total",              :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.string   "add_items"
    t.integer  "job_number"
    t.integer  "customer_id"
    t.integer  "company_id"
    t.datetime "created_at",                                                            :null => false
    t.datetime "updated_at",                                                            :null => false
    t.integer  "contact_id"
    t.integer  "jobsite_id"
    t.string   "name"
    t.text     "signature"
    t.string   "image_file_name"
    t.integer  "image_file_size"
    t.string   "image_content_type"
    t.datetime "image_updated_at"
    t.decimal  "total"
    t.decimal  "quickbook_tax_amount"
    t.decimal  "quickbook_total_amount"
  end

  add_index "jobs", ["reference_no"], :name => "index_jobs_on_reference_no", :unique => true

  create_table "jobsites", :force => true do |t|
    t.string   "name"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.integer  "customer_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "gmaps",       :default => false
  end

  create_table "jobstatuses", :force => true do |t|
    t.string   "status"
    t.integer  "company_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "jobtimes", :force => true do |t|
    t.string   "timetype"
    t.string   "qty"
    t.string   "user"
    t.string   "service"
    t.integer  "job_id"
    t.integer  "jobsite_id"
    t.integer  "company_id"
    t.integer  "customer_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean  "billable",    :default => true
    t.decimal  "cost"
    t.decimal  "price"
  end

  create_table "notes", :force => true do |t|
    t.string   "note_type"
    t.text     "description"
    t.integer  "notable_id"
    t.string   "notable_type"
    t.integer  "company_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "jobsite_id"
  end

  create_table "payments", :force => true do |t|
    t.string   "payment_type"
    t.string   "amount"
    t.string   "card_number"
    t.date     "expires"
    t.string   "data"
    t.string   "check_number"
    t.string   "po_number"
    t.string   "tax"
    t.string   "balance"
    t.integer  "job_id"
    t.integer  "company_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "recurrings", :force => true do |t|
    t.string   "name"
    t.string   "template_type"
    t.string   "interval"
    t.string   "days_inadvance"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "job_id"
    t.integer  "company_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "every"
    t.string   "on"
    t.integer  "customer_id"
    t.integer  "jobsite_id"
  end

  create_table "roles", :force => true do |t|
    t.string   "roll"
    t.boolean  "module"
    t.string   "customer"
    t.string   "jobs"
    t.string   "contacts"
    t.string   "reports"
    t.string   "settings_admin"
    t.integer  "company_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "jobtimes"
  end

  create_table "subscriptions", :force => true do |t|
    t.integer  "company_id"
    t.string   "plan"
    t.string   "stripe_card_token"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "amount"
  end

  create_table "superadmins", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "user_name"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "superadmins", ["email"], :name => "index_superadmins_on_email", :unique => true
  add_index "superadmins", ["reset_password_token"], :name => "index_superadmins_on_reset_password_token", :unique => true

  create_table "tabs", :force => true do |t|
    t.string   "name"
    t.string   "tab_type"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "company_id"
  end

  create_table "users", :force => true do |t|
    t.integer  "role_id"
    t.string   "name"
    t.string   "accounting_type"
    t.string   "accounting_name"
    t.string   "email"
    t.boolean  "smo_user",               :default => true
    t.string   "language"
    t.string   "time_zone"
    t.integer  "company_id"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.string   "encrypted_password",     :default => "",   :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "authentication_token"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
