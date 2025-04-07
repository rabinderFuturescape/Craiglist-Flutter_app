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

CREATE TABLE IF NOT EXISTS public.cart_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(user_id, product_id)
);

CREATE TABLE IF NOT EXISTS public.orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  total_amount DECIMAL(10, 2) NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  shipping_address JSONB,
  payment_method TEXT,
  payment_status TEXT DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE SET NULL,
  product_title TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL,
  reference_id UUID,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Create RLS policies
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.looking_for_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

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

-- Create policies for cart_items
CREATE POLICY "Users can view their own cart items" 
  ON public.cart_items FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own cart items" 
  ON public.cart_items FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own cart items" 
  ON public.cart_items FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own cart items" 
  ON public.cart_items FOR DELETE USING (auth.uid() = user_id);

-- Create policies for orders
CREATE POLICY "Users can view their own orders" 
  ON public.orders FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own orders" 
  ON public.orders FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own orders" 
  ON public.orders FOR UPDATE USING (auth.uid() = user_id);

-- Create policies for order_items
CREATE POLICY "Users can view their own order items" 
  ON public.order_items FOR SELECT USING (
    auth.uid() IN (
      SELECT user_id FROM public.orders WHERE id = order_id
    )
  );

-- Create policies for notifications
CREATE POLICY "Users can view their own notifications" 
  ON public.notifications FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications" 
  ON public.notifications FOR UPDATE USING (auth.uid() = user_id);

-- Create functions and triggers
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.notifications (user_id, title, message, type)
  VALUES (
    NEW.id, 
    'Welcome to Craigslist Flutter App', 
    'Thank you for joining our community!', 
    'SYSTEM'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
