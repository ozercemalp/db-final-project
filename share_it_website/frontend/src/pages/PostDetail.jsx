import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { useParams, Link } from 'react-router-dom';
import PostCard from '../components/PostCard';
import { useAuth } from '../AuthContext';

const PostDetail = () => {
    const { postId } = useParams();
    const { user } = useAuth();
    const [post, setPost] = useState(null);
    const [comments, setComments] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    const [commentText, setCommentText] = useState("");
    const [submitting, setSubmitting] = useState(false);

    const handleCommentSubmit = async () => {
        if (!commentText.trim()) return;
        setSubmitting(true);
        try {
            await axios.post(`/api/posts/${postId}/comments`, {
                user_id: user.user_id,
                content: commentText
            });
            setCommentText("");
            // Refresh comments
            const userIdParam = user ? `?current_user_id=${user.user_id}` : '';
            const res = await axios.get(`/api/posts/${postId}${userIdParam}`);
            setComments(res.data.comments);
        } catch (err) {
            console.error("Failed to submit comment", err);
            alert("Failed to submit comment: " + (err.response?.data?.error || err.message));
        } finally {
            setSubmitting(false);
        }
    };

    useEffect(() => {
        const fetchPostDetails = async () => {
            setLoading(true);
            try {
                const userIdParam = user ? `?current_user_id=${user.user_id}` : '';
                const res = await axios.get(`/api/posts/${postId}${userIdParam}`);
                setPost(res.data.post);
                setComments(res.data.comments);
            } catch (err) {
                console.error("Failed to fetch post details", err);
                setError(err.message);
            } finally {
                setLoading(false);
            }
        };
        fetchPostDetails();
    }, [postId, user]);

    if (loading) return <div className="container mx-auto py-4 text-center">Loading...</div>;
    if (error) return <div className="container mx-auto py-4 text-center text-red-500">Error: {error}</div>;
    if (!post) return <div className="container mx-auto py-4 text-center">Post not found</div>;

    return (
        <div className="container mx-auto py-4 px-2 md:px-0 flex justify-center">
            <div className="w-full md:w-2/3 lg:w-1/2">
                <Link to="/" className="text-gray-500 hover:underline mb-4 inline-block">&larr; Back to Home</Link>

                {/* Re-use PostCard but maybe we generally want a "Full Post" view? 
                    For now, PostCard is fine, but we might want to hide the "Comments" button or make it just a label.
                    But reuse is efficient. */}
                <PostCard post={post} />

                <div className="bg-white rounded border border-gray-300 p-4 mt-4">
                    <h3 className="text-lg font-bold mb-4">Comments</h3>

                    {/* Add Comment */}
                    <div className="mb-6">
                        <textarea
                            className="w-full border border-gray-300 rounded p-2"
                            placeholder="What are your thoughts?"
                            rows="3"
                            disabled={!user || submitting}
                            value={commentText}
                            onChange={(e) => setCommentText(e.target.value)}
                        />
                        <div className="flex justify-end mt-2">
                            <button
                                onClick={handleCommentSubmit}
                                className={`px-4 py-1 rounded text-white font-bold ${!user || submitting ? 'bg-gray-400 cursor-not-allowed' : 'bg-blue-500 hover:bg-blue-600'}`}
                                disabled={!user || submitting}
                            >
                                {submitting ? 'Posting...' : 'Comment'}
                            </button>
                        </div>
                        {!user && <p className="text-sm text-gray-500 mt-1">Log in to comment</p>}
                    </div>

                    <div className="space-y-4">
                        {comments.length > 0 ? (
                            comments.map(comment => (
                                <div key={comment.COMMENT_ID} className="border-b border-gray-100 pb-3 last:border-0">
                                    <div className="text-xs text-gray-500 mb-1">
                                        <span className="font-bold text-gray-700">{comment.USERNAME}</span>
                                        <span className="mx-1">•</span>
                                        <span>{new Date(comment.CREATED_AT).toLocaleDateString()}</span>
                                    </div>
                                    <p className="text-gray-800 text-sm">{comment.CONTENT_TEXT}</p>
                                </div>
                            ))
                        ) : (
                            <p className="text-gray-500 text-center py-4">No comments yet.</p>
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
};

export default PostDetail;
