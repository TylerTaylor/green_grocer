require 'pry'

def consolidate_cart(cart)
  consolidated = {}

  cart.each do |item|
    # item => {"TEMPEH"=>{:price=>3.0, :clearance=>true}}
    item.each do |item_name, properties|

      # if we already have this key in the consolidated hash, add 1 to count
      if consolidated[item_name]
        consolidated[item_name][:count] += 1
      else
        # otherwise we need to set up the key to have an initial count of 1
        consolidated[item_name] = {
          price: properties[:price],
          clearance: properties[:clearance],
          count: 1
        }
      end

    end
  end

  consolidated
end

def apply_coupons(cart, coupons)
  coupons.each do |coupon|
    item = coupon[:item]

    # if the cart definitely has a key that matches the couponed item
    #   AND that item in the cart has at least as many "in stock" as the amount of coupons
    if cart[item] && cart[item][:count] >= coupon[:num]
      
      # if we've already created the key of "item W/COUPON", we can increase the count
      if cart["#{item} W/COUPON"]
        cart["#{item} W/COUPON"][:count] += 1
      else
        # otherwise we need to create the key of "item W/COUPON" and set up an initial count
        cart["#{item} W/COUPON"] = {
          price: coupon[:cost],
          clearance: cart[item][:clearance],
          count: 1
        }
      end

      # after all that is set up we need to subtract the number of coupons from the related item in the cart
      cart[item][:count] -= coupon[:num]

    end # end if
  end # end each

  cart
end

def apply_clearance(cart)
  cart.each do |item, properties|
    # if clearance is true, apply discount
    if properties[:clearance]
      cart[item][:price] = (cart[item][:price] * 0.8).round(2)
    end
  end

  cart
end

def checkout(cart, coupons)
  consolidated = consolidate_cart(cart)
  coupons_applied = apply_coupons(consolidated, coupons)
  complete_cart = apply_clearance(coupons_applied)

  total = 0

  complete_cart.each do |item, properties|
    total += properties[:price] * properties[:count]
  end

  if total > 100
    total = total * 0.9
  end
  
  total
end
