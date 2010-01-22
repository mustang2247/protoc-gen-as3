// vim: tabstop=4 shiftwidth=4

// Copyright (c) 2010 , 杨博 (Yang Bo) All rights reserved.
//
//         pop.atry@gmail.com
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.protobuf {
	import flash.utils.*
	import flash.errors.*
	public final class PostposeLengthBuffer extends ByteArray {
		[ArrayElementType("uint")]
		private const slices:Array = []
		public function beginBlock():uint {
			if (beginSliceIndex % 2 != 0) {
				throw new IllegalOperationError
			}
			slices.push(position)
			const beginSliceIndex:uint = slices.length
			slices.length += 2
			slices.push(position)
			return beginSliceIndex
		}
		public function endBlock(beginSliceIndex:uint):void {
			if (slices.length % 2 != 0) {
				throw new IllegalOperationError
			}
			slices.push(position)
			const beginPosition:uint = slices[beginSliceIndex + 2]
			slices[beginSliceIndex] = position
			WriteUtils.write_TYPE_UINT32(this, position - beginPosition)
			slices[beginSliceIndex + 1] = position
			slices.push(position)
		}
		public function toNormal(output:IDataOutput):void {
			if (slices.length % 2 != 0) {
				throw new IllegalOperationError
			}
			var i:uint = 0
			var begin:uint = 0
			do {
				var end:uint = slices[i]
				++i
				if (end > begin) {
					output.writeBytes(this, begin, end - begin)
				} else if (end < begin) {
					throw new IllegalOperationError
				}
				begin = slices[i]
				++i
			} while (i < slices.length)
			output.writeBytes(this, begin)
		}
	}
}