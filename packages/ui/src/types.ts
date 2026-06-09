export type OrderStatus =
  | 'draft'
  | 'pending_payment'
  | 'paid'
  | 'accepted_by_distributor'
  | 'in_fulfillment'
  | 'shipped'
  | 'delivered'
  | 'completed'
  | 'cancelled'
  | 'disputed'

export type BadgeTone = 'neutral' | 'brand' | 'success' | 'warning' | 'danger' | 'info'
