# Supabase Local Development

This directory contains configuration for running Supabase locally using Docker Compose.

## Getting Started

1. Make sure you have Docker and Docker Compose installed on your machine.

2. Start the Supabase services:
   ```bash
   docker-compose up -d
   ```

3. Access Supabase Studio at http://localhost:3000

4. To stop the services:
   ```bash
   docker-compose down
   ```

## Services

The following services are included:

- **PostgreSQL**: The database (port 5432)
- **Supabase Studio**: Web UI for managing your database (port 3000)
- **Kong**: API Gateway (port 8000)
- **GoTrue**: Authentication service
- **PostgREST**: RESTful API for PostgreSQL
- **Realtime**: Realtime subscriptions
- **Storage**: File storage service
- **imgproxy**: Image processing service

## Configuration

The default configuration uses the following credentials:

- **Database**:
  - User: `postgres`
  - Password: `postgres`
  - Database: `postgres`

- **API**:
  - Anon Key: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpc3MiOiAic3VwYWJhc2UtZGVtbyIsCiAgICAiaWF0IjogMTY0MTc2OTIwMCwKICAgICJleHAiOiAxNzk5NTM1NjAwCn0.dc_X5iR_VP_qT0zsiyj_I_OZ2T9FtRU2BBNWN8Bu4GE`
  - Service Key: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJzZXJ2aWNlX3JvbGUiLAogICAgImlzcyI6ICJzdXBhYmFzZS1kZW1vIiwKICAgICJpYXQiOiAxNjQxNzY5MjAwLAogICAgImV4cCI6IDE3OTk1MzU2MDAKfQ.DaYlNEoUrrEn2Ig7tqibS-PHK5vgusbcbo7X36XVt4Q`

## Database Migrations

Create a `migrations` directory to store your SQL migrations:

```bash
mkdir -p supabase/migrations
```

Example migration file (`supabase/migrations/001_initial_schema.sql`):

```sql
-- Create tables
CREATE TABLE IF NOT EXISTS public.products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  image_urls TEXT[] DEFAULT '{}',
  categories TEXT[] DEFAULT '{}',
  location TEXT,
  date_posted TIMESTAMP WITH TIME ZONE DEFAULT now(),
  expiry_date TIMESTAMP WITH TIME ZONE,
  is_available BOOLEAN DEFAULT true,
  seller_id UUID NOT NULL,
  seller_name TEXT,
  seller_contact TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.looking_for_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  budget DECIMAL(10, 2),
  categories TEXT[] DEFAULT '{}',
  location TEXT,
  date_posted TIMESTAMP WITH TIME ZONE DEFAULT now(),
  expiry_date TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN DEFAULT true,
  user_id UUID NOT NULL,
  user_name TEXT,
  user_contact TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Create RLS policies
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.looking_for_items ENABLE ROW LEVEL SECURITY;

-- Create policies for products
CREATE POLICY "Products are viewable by everyone" 
  ON public.products FOR SELECT USING (true);

CREATE POLICY "Users can insert their own products" 
  ON public.products FOR INSERT WITH CHECK (auth.uid() = seller_id);

CREATE POLICY "Users can update their own products" 
  ON public.products FOR UPDATE USING (auth.uid() = seller_id);

CREATE POLICY "Users can delete their own products" 
  ON public.products FOR DELETE USING (auth.uid() = seller_id);

-- Create policies for looking_for_items
CREATE POLICY "Looking for items are viewable by everyone" 
  ON public.looking_for_items FOR SELECT USING (true);

CREATE POLICY "Users can insert their own looking for items" 
  ON public.looking_for_items FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own looking for items" 
  ON public.looking_for_items FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own looking for items" 
  ON public.looking_for_items FOR DELETE USING (auth.uid() = user_id);
```

To apply migrations, you can use the Supabase CLI or run them directly in the Supabase Studio SQL editor.
