json.extract! contact, :id, :name, :number, :picture, :created_at, :updated_at
json.url contact_url(contact, format: :json)
