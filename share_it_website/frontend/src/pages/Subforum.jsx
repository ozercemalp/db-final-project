import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { useParams } from 'react-router-dom';
import PostCard from '../components/PostCard';
import { useAuth } from '../AuthContext';

const Subforum = () => {
    const { user } = useAuth();
    const { subforumName } = useParams(); // Capture /r/:subforumName
    const [posts, setPosts] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        const fetchPosts = async () => {
            setLoading(true);
            setError(null);
            try {
                console.log(`Fetching posts for: ${subforumName}`);
                // Pass the subforum name as a query param
                const userIdParam = user ? `&current_user_id=${user.user_id}` : '';
                const res = await axios.get(`/api/posts?subforum_name=${subforumName}${userIdParam}`);
                console.log("Got response:", res.data);
                setPosts(res.data);
            } catch (err) {
                console.error("Failed to fetch posts", err);
                if (err.response && err.response.status === 404) {
                    setError("Subforum not found");
                } else if (err.response && err.response.data && err.response.data.error) {
                    setError(err.response.data.error);
                } else {
                    setError(err.message || "Unknown error");
                }
            } finally {
                setLoading(false);
            }
        };
        fetchPosts();
    }, [subforumName]); // Refetch if URL changes

    return (
        <div className="container mx-auto py-4 px-2 md:px-0 flex justify-center">
            <div className="w-full md:w-2/3 lg:w-1/2">
                {/* Debug Info */}
                <div className="bg-yellow-100 p-2 text-xs mb-2 font-mono">
                    DEBUG: Subforum="{subforumName}" | Loading={loading.toString()} | Posts={posts.length} | Error={error}
                </div>

                <div className="bg-white p-4 rounded border border-gray-300 mb-4">
                    <h1 className="text-2xl font-bold">r/{subforumName}</h1>
                    <p className="text-gray-500">Welcome to the {subforumName} community.</p>
                </div>

                {error === "Subforum not found" ? (
                    <div className="text-center py-10">
                        <h2 className="text-xl font-bold text-gray-700">r/{subforumName} does not exist</h2>
                        <p className="text-gray-500 mt-2">Check the spelling or go back home.</p>
                        <button onClick={() => window.location.href = '/'} className="mt-4 bg-blue-500 text-white px-4 py-2 rounded">Go Home</button>
                    </div>
                ) : error ? (
                    <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4" role="alert">
                        <strong className="font-bold">Error!</strong>
                        <span className="block sm:inline"> {error}</span>
                    </div>
                ) : loading ? (
                    <p>Loading...</p>
                ) : posts.length > 0 ? (
                    posts.map(post => <PostCard key={post.POST_ID} post={post} />)
                ) : (
                    <div className="text-center py-10 text-gray-500">
                        No posts here yet. Be the first to post!
                    </div>
                )}
            </div>

            {/* Sidebar (Optional: You could fetch subforum rules/details here later) */}
            <div className="hidden md:block w-1/3 ml-4">
                <div className="bg-white border border-gray-300 p-4 rounded mb-4">
                    <h2 className="font-bold mb-2">About r/{subforumName}</h2>
                    <p className="text-sm text-gray-600">
                        Community specific details could go here.
                    </p>
                </div>
            </div>
        </div>
    );
};

export default Subforum;
