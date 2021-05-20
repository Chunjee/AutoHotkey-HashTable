class hashtable
{
	__New(Items*)
	{
		local
		; An AutoHotkey Array takes the place of the array that would normally
		; be used to implement a hash table's buckets.
		;
		; Masking to remove the unwanted high bits to fit within the array
		; bounds is unnecessary because AutoHotkey Arrays are sparse arrays that
		; support negative indices.
		;
		; Rehashing everything and placing it in a new array that has the next
		; highest power of 2 elements when over 3/4ths of the buckets are full
		; is unnecessary for the same reason.
		;
		; Separate chaining (instead of Robin Hood hashing with a low probe
		; count and backwards shift deletion) is used to resolve hash collisions
		; because it is more time efficient when locality of reference is a lost
		; cause.
		this._Buckets := []
		this._Count   := 0
		loop % Items.Length()
		{
			if (!Items.hasKey(A_Index)) {
				throw Exception("Missing Argument Defect", -1, "hashtable.__New(Items*)")
			}
			if (   !(    IsObject(Items[A_Index])
						and Items[A_Index].hasKey("hasKey") != "")
				or !(    Items[A_Index].hasKey(1)
						and Items[A_Index].hasKey(2)
						and Items[A_Index].Count() == 2)) {
				throw Exception("Type Defect", -1, "hashtable.__New(Items*)  Invalid argument.")
			}
			this.create(Items[A_Index][1], Items[A_Index][2])
		}
		return this
	}

	count()
	{
		return this._Count
	}
	size()
	{
		return this._Count
	}

	_GetHash(Key)
	{
		; _GetHash(Key) is used to find the bucket a key would be stored in.
		local
		if (IsObject(Key))
		{
			Hash := &Key
		} else {
			if Key is integer
			{
				Hash := Key
			}
			else if Key is float
			{
				TruncatedKey := Key & -1
				if (Key == TruncatedKey) {
					Hash := TruncatedKey
				} else {
					; This reinterpret casts a floating point value to an
					; Integer with the same bitwise representation.
					;
					; Removing the first step will result in warnings about
					; reading an uninitialized variable if warnings are turned
					; on.
					VarSetCapacity(Hash, 8)
					NumPut(Key, Hash,, "Double")
					Hash := NumGet(Hash,, "Int64")
				}
			} else {
				; This is the String hashing algorithm used in Java.  It makes
				; use of modular arithmetic via Integer overflow.
				Hash := 0
				for _, Char in StrSplit(Key) {
					Hash := 31 * Hash + Ord(Char)
				}
			}
		}
		return Hash
	}

	hasKey(Key)
	{
		local
		Found := false
		Hash  := this._GetHash(Key)
		Item  := this._Buckets.hasKey(Hash) ? this._Buckets[Hash] : ""
		while (!Found and Item != "") {
			if (Item.Key == Key) {
				Found := true
			} else {
				Item := Item.Next
			}
		}
		return Found
	}

	create(Key, Value)
	{
		local
		Found        := false
		Hash         := this._GetHash(Key)
		Item         := this._Buckets.hasKey(Hash) ? this._Buckets[Hash] : ""
		PreviousItem := ""
		while (!Found and Item != "") {
			if (Item.Key == Key) {
				Item.Value := Value
				; Perform chain reordering to speed up future lookups.
				if (PreviousItem != "") {
					PreviousItem.Next   := Item.Next
					Item.Next           := this._Buckets[Hash]
					this._Buckets[Hash] := Item
				}
				Found := true
			} else {
				PreviousItem := Item
				Item         := Item.Next
			}
		}
		if (!Found)
		{
			Next                      := this._Buckets.hasKey(Hash) ? this._Buckets[Hash] : ""
			this._Buckets[Hash]       := {}
			this._Buckets[Hash].Key   := Key
			this._Buckets[Hash].Value := Value
			this._Buckets[Hash].Next  := Next
			this._Buckets[Hash].SetCapacity(0)
			this._Count               += 1
			return true
		}
		return true
	}

	read(Key)
	{
		local
		Found := false
		Hash  := this._GetHash(Key)
		Item  := this._Buckets.hasKey(Hash) ? this._Buckets[Hash] : ""
		while (!Found) {
			if (Item == "")	{
				return ""
			}
			if (Item.Key == Key) {
				Value := Item.Value
				Found := true
			} else {
				Item := Item.Next
			}
		}
		return Value
	}

	update(Key, Value)
	{
		return this.create(Key, Value)
	}



	delete(Key)
	{
		local
		Found        := false
		Hash         := this._GetHash(Key)
		Item         := this._Buckets.hasKey(Hash) ? this._Buckets[Hash] : ""
		PreviousItem := ""
		while (!Found) {
			if (Item == "")	{
				return false
			}
			if (Item.Key == Key) {
				Value := Item.Value
				if (PreviousItem == "")	{
					if (Item.Next == "") {
						this._Buckets.Delete(Hash)
					} else {
						this._Buckets[Hash] := Item.Next
					}
				} else {
					PreviousItem.Next := Item.Next
				}
				this._Count -= 1
				Found := true
			} else {
				PreviousItem := Item
				Item         := Item.Next
			}
		}
		return Item.Key
	}

	clear()
	{
		local
		this._Buckets := []
		this._Count   := 0
	}

	clone()
	{
		local
		global hashtable
		Clone := new hashtable()
		; Avoid rehashing when cloning.
		for Hash, Item in this._Buckets {
			PreviousItemClone := ""
			while (Item != "") {
				ItemClone := Item.clone()
				if (PreviousItemClone == "") {
					Chain := ItemClone
				} else {
					PreviousItemClone.Next := ItemClone
				}
				PreviousItemClone := ItemClone
				Item              := Item.Next
			}
			Clone._Buckets[Hash] := Chain
		}
		Clone._Count := this._Count
		return Clone
	}

	class Enumerator
	{
		__New(hashtable)
		{
			local
			this._BucketsEnum  := hashtable._Buckets._NewEnum()
			this._PreviousItem := ""
			return this
		}

		Next(byref Key, byref Value := "")
		{
			local
			if (this._PreviousItem == "" || this._PreviousItem.Next == "") {
				Result := this._BucketsEnum.Next(_, Item)
			} else {
				Item   := this._PreviousItem.Next
				Result := true
			}
			if (Result) {
				Key                := Item.Key
				Value              := Item.Value
				this._PreviousItem := Item
			}
			return Result
		}
	}

	_NewEnum()
	{
		local
		global hashtable
		return new hashtable.Enumerator(this)
	}
}
